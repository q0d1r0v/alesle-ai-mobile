package com.alesle.ai.device

import android.content.Context
import android.media.MediaRecorder
import android.os.Build
import java.io.File

/**
 * Push-to-talk recording (SOW 04 §4.1): AAC in ADTS, 16 kHz mono, 32 kbps —
 * a minute is ~240 KB. Files live in the app cache and are deleted after
 * upload by whoever took them.
 */
class VoiceRecorder(
    private val context: Context,
    private val newRecorder: () -> MediaRecorder = { defaultRecorder(context) },
    private val now: () -> Long = System::currentTimeMillis,
) {
    private var recorder: MediaRecorder? = null
    private var file: File? = null
    private var startedAt = 0L

    fun start() {
        cancel()
        val target = File(context.cacheDir, "voice-${now()}.aac")
        val created = newRecorder()
        try {
            created.setAudioSource(MediaRecorder.AudioSource.VOICE_RECOGNITION)
            created.setOutputFormat(MediaRecorder.OutputFormat.AAC_ADTS)
            created.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            created.setAudioSamplingRate(SAMPLE_RATE)
            created.setAudioChannels(1)
            created.setAudioEncodingBitRate(BIT_RATE)
            created.setMaxDuration(MAX_DURATION_MS)
            created.setOutputFile(target.absolutePath)
            created.prepare()
            created.start()
        } catch (e: java.io.IOException) {
            fail(created, target, e)
        } catch (e: RuntimeException) {
            fail(created, target, e)
        }
        recorder = created
        file = target
        startedAt = now()
    }

    private fun fail(
        created: MediaRecorder,
        target: File,
        cause: Exception,
    ): Nothing {
        created.release()
        target.delete()
        throw IllegalStateException("microphone_unavailable", cause)
    }

    /** The recording's path, or null when it was too short to hold a word. */
    fun stop(): String? {
        val active = recorder ?: return null
        val target = file
        val long = now() - startedAt >= MIN_DURATION_MS
        recorder = null
        file = null
        val stopped =
            try {
                active.stop()
                true
            } catch (e: RuntimeException) {
                // MediaRecorder throws when stopped before any audio was written.
                false
            } finally {
                active.release()
            }
        if (!stopped || !long || target == null || target.length() == 0L) {
            target?.delete()
            return null
        }
        return target.absolutePath
    }

    fun cancel() {
        recorder?.let {
            try {
                it.stop()
            } catch (e: RuntimeException) {
                // Nothing recorded yet.
            } finally {
                it.release()
            }
        }
        file?.delete()
        recorder = null
        file = null
    }

    companion object {
        const val SAMPLE_RATE = 16_000
        const val BIT_RATE = 32_000
        const val MAX_DURATION_MS = 60_000
        const val MIN_DURATION_MS = 400L

        private fun defaultRecorder(context: Context): MediaRecorder =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                MediaRecorder(context)
            } else {
                @Suppress("DEPRECATION") // The Context constructor exists from Android 12.
                MediaRecorder()
            }
    }
}
