package com.alesle.ai.listen

import android.Manifest
import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.media.audiofx.AcousticEchoCanceler
import android.media.audiofx.NoiseSuppressor
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.alesle.ai.R
import java.io.File

/**
 * Hands-free listening (SOW 04 §4.3): keeps the microphone open while the
 * user wants it, in the foreground with an ongoing notification ("Alesle
 * tinglayapti" — Mute / Turn off), and passes each utterance to the app as a
 * WAV file. Nothing is recorded while muted; audio between utterances is
 * dropped as it comes.
 *
 * Android only lets an app start a microphone service while it is in front,
 * so the app starts it; it then keeps listening in the background.
 */
class ListeningService : Service() {
    private var engine: HandsFreeEngine? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        val channel =
            NotificationChannel(CHANNEL_ID, getString(R.string.notification_channel_listening), NotificationManager.IMPORTANCE_LOW)
                .apply { setShowBadge(false) }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
        instance = this
    }

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int,
    ): Int {
        when (intent?.action) {
            ACTION_OFF -> {
                shutDown()
                return START_NOT_STICKY
            }
            ACTION_MUTE -> HandsFree.update(HandsFree.state.copy(muted = true))
            ACTION_UNMUTE -> HandsFree.update(HandsFree.state.copy(muted = false))
        }
        if (!goForeground()) {
            shutDown()
            return START_NOT_STICKY
        }
        if (engine == null) {
            val created =
                HandsFreeEngine(
                    openSource = { MicrophoneSource.open(this) },
                    // Live hears the user over Alesle's voice (barge-in); otherwise it must not hear itself.
                    quiet = { if (LiveVoice.handlesSpeech) HandsFree.state.muted else HandsFree.isQuiet() },
                    onUtterance = { pcm -> if (!LiveVoice.handlesSpeech) save(pcm) },
                    onSourceLost = { shutDown() },
                    stream = LiveVoice,
                    strict = { LiveVoice.strict },
                )
            if (!created.start()) {
                shutDown()
                return START_NOT_STICKY
            }
            engine = created
            HandsFree.update(HandsFree.state.copy(active = true))
        }
        notify(HandsFree.state.muted)
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        engine?.stop()
        engine = null
        LiveVoice.stop()
        if (instance === this) instance = null
        HandsFree.update(ListenState(active = false, muted = HandsFree.state.muted))
        super.onDestroy()
    }

    private fun goForeground(): Boolean =
        try {
            val notification = build(HandsFree.state.muted)
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE)
            true
        } catch (e: RuntimeException) {
            // Started from the background (Android 14+), or the permission was taken away.
            false
        }

    private fun shutDown() {
        engine?.stop()
        engine = null
        LiveVoice.stop()
        HandsFree.update(ListenState(active = false, muted = HandsFree.state.muted))
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    /** One utterance to a WAV file in the cache, then to the app; whoever takes it deletes it. */
    private fun save(pcm: ShortArray) {
        val file = File(cacheDir, "utterance-${System.nanoTime()}.wav")
        try {
            Wav.write(file, pcm)
        } catch (e: java.io.IOException) {
            file.delete()
            return
        }
        HandsFree.deliver(file.absolutePath)
    }

    private fun notify(muted: Boolean) {
        getSystemService(NotificationManager::class.java).notify(NOTIFICATION_ID, build(muted))
    }

    private fun build(muted: Boolean): Notification {
        val toggle = if (muted) action(ACTION_UNMUTE, REQUEST_UNMUTE) else action(ACTION_MUTE, REQUEST_MUTE)
        val launch = packageManager.getLaunchIntentForPackage(packageName)
        return NotificationCompat
            .Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_alesle)
            .setContentTitle(getString(if (muted) R.string.notification_listening_muted else R.string.notification_listening))
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)
            .setContentIntent(
                launch?.let {
                    PendingIntent.getActivity(
                        this,
                        REQUEST_OPEN,
                        it,
                        PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
                    )
                },
            ).addAction(0, getString(if (muted) R.string.notification_listening_unmute else R.string.notification_listening_mute), toggle)
            .addAction(0, getString(R.string.notification_listening_off), action(ACTION_OFF, REQUEST_OFF))
            .build()
    }

    private fun action(
        name: String,
        request: Int,
    ): PendingIntent =
        PendingIntent.getService(
            this,
            request,
            Intent(this, ListeningService::class.java).setAction(name),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )

    /** 16 kHz mono PCM from the microphone, tuned for speech, with the platform's cleanup when it has it. */
    private class MicrophoneSource(
        private val record: AudioRecord,
        private val effects: List<android.media.audiofx.AudioEffect>,
    ) : PcmSource {
        override fun read(frame: ShortArray): Int {
            var at = 0
            while (at < frame.size) {
                val read = record.read(frame, at, frame.size - at)
                if (read <= 0) return -1
                at += read
            }
            return at
        }

        override fun close() {
            effects.forEach { it.release() }
            try {
                record.stop()
            } catch (e: IllegalStateException) {
                // Never started.
            }
            record.release()
        }

        companion object {
            @SuppressLint("MissingPermission") // Checked just above.
            fun open(context: Context): PcmSource? {
                if (ContextCompat.checkSelfPermission(context, Manifest.permission.RECORD_AUDIO) != PackageManager.PERMISSION_GRANTED) {
                    return null
                }
                val min =
                    AudioRecord.getMinBufferSize(
                        VoiceActivityDetector.SAMPLE_RATE,
                        AudioFormat.CHANNEL_IN_MONO,
                        AudioFormat.ENCODING_PCM_16BIT,
                    )
                if (min <= 0) return null
                val record =
                    try {
                        AudioRecord(
                            MediaRecorder.AudioSource.VOICE_RECOGNITION,
                            VoiceActivityDetector.SAMPLE_RATE,
                            AudioFormat.CHANNEL_IN_MONO,
                            AudioFormat.ENCODING_PCM_16BIT,
                            maxOf(min, VoiceActivityDetector.FRAME_SAMPLES * 2 * 8),
                        )
                    } catch (e: IllegalArgumentException) {
                        return null
                    }
                if (record.state != AudioRecord.STATE_INITIALIZED) {
                    record.release()
                    return null
                }
                val effects =
                    listOfNotNull(
                        if (NoiseSuppressor.isAvailable()) {
                            NoiseSuppressor
                                .create(
                                    record.audioSessionId,
                                )?.apply { enabled = true }
                        } else {
                            null
                        },
                        if (AcousticEchoCanceler.isAvailable()) {
                            AcousticEchoCanceler
                                .create(
                                    record.audioSessionId,
                                )?.apply { enabled = true }
                        } else {
                            null
                        },
                    )
                try {
                    record.startRecording()
                } catch (e: IllegalStateException) {
                    effects.forEach { it.release() }
                    record.release()
                    return null
                }
                if (record.recordingState != AudioRecord.RECORDSTATE_RECORDING) {
                    effects.forEach { it.release() }
                    record.release()
                    return null
                }
                return MicrophoneSource(record, effects)
            }
        }
    }

    companion object {
        const val CHANNEL_ID = "listening"
        const val NOTIFICATION_ID = 2
        const val ACTION_START = "com.alesle.ai.listen.START"
        const val ACTION_MUTE = "com.alesle.ai.listen.MUTE"
        const val ACTION_UNMUTE = "com.alesle.ai.listen.UNMUTE"
        const val ACTION_OFF = "com.alesle.ai.listen.OFF"
        private const val REQUEST_OPEN = 20
        private const val REQUEST_MUTE = 21
        private const val REQUEST_UNMUTE = 22
        private const val REQUEST_OFF = 23

        @Volatile
        private var instance: ListeningService? = null

        /** Debug builds: speaks [pcm] to the running listener instead of the microphone. */
        fun inject(pcm: ShortArray): Boolean {
            val engine = instance?.engine ?: return false
            engine.inject(pcm)
            return true
        }

        /** False when Android refuses (the app is not in front, Android 14+). */
        fun start(context: Context): Boolean = send(context, ACTION_START)

        fun setMuted(
            context: Context,
            muted: Boolean,
        ) {
            if (!HandsFree.state.active) {
                HandsFree.update(HandsFree.state.copy(muted = muted))
                return
            }
            send(context, if (muted) ACTION_MUTE else ACTION_UNMUTE)
        }

        fun stop(context: Context) {
            if (instance == null) return
            context.startService(Intent(context, ListeningService::class.java).setAction(ACTION_OFF))
        }

        private fun send(
            context: Context,
            action: String,
        ): Boolean =
            try {
                ContextCompat.startForegroundService(context, Intent(context, ListeningService::class.java).setAction(action))
                true
            } catch (e: IllegalStateException) {
                false
            } catch (e: SecurityException) {
                false
            }
    }
}
