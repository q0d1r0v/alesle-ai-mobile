package com.alesle.ai.listen

import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioTrack
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit

/** Plays the live model's voice as it streams in. */
interface VoiceSink {
    /** Something is queued or still playing. */
    val playing: Boolean

    /** Called (on any thread) once everything queued has played out. */
    var onDrained: (() -> Unit)?

    /** 24 kHz mono PCM16, appended to what is playing. */
    fun play(pcm: ByteArray)

    /** Drops whatever is queued or playing, at once (the user spoke over it). */
    fun stop()

    fun release()
}

/**
 * [VoiceSink] on a streaming [AudioTrack], fed by its own thread so the
 * socket never waits for the speaker. A stop bumps the generation: chunks
 * of the old reply are dropped and the track is flushed.
 */
class LivePlayer(
    private val speaking: (Boolean) -> Unit = { HandsFree.setSpeaking(it) },
) : VoiceSink {
    private class Chunk(
        val generation: Int,
        val pcm: ByteArray,
    )

    private val queue = LinkedBlockingQueue<Chunk>()

    @Volatile
    private var generation = 0

    @Volatile
    private var active = false

    @Volatile
    private var track: AudioTrack? = null

    private var thread: Thread? = null

    override val playing: Boolean get() = active

    @Volatile
    override var onDrained: (() -> Unit)? = null

    @Synchronized
    override fun play(pcm: ByteArray) {
        if (pcm.isEmpty()) return
        if (!active) {
            active = true
            speaking(true)
        }
        queue.add(Chunk(generation, pcm))
        if (thread == null) {
            thread =
                Thread(::loop, "alesle-live-voice").apply {
                    isDaemon = true
                    start()
                }
        }
    }

    @Synchronized
    override fun stop() {
        generation++
        queue.clear()
        runCatching { track?.pause() }
        if (active) {
            active = false
            speaking(false)
        }
    }

    @Synchronized
    override fun release() {
        stop()
        thread?.interrupt()
        thread = null
    }

    private fun loop() {
        var current: AudioTrack? = null
        var currentGeneration = -1
        var written = 0L
        var lastHead = -1L
        var stalled = 0
        try {
            while (!Thread.currentThread().isInterrupted) {
                val chunk = queue.poll(POLL_MS, TimeUnit.MILLISECONDS)
                val now = generation
                if (current != null && currentGeneration != now) {
                    drop(current)
                    current = null
                    written = 0
                }
                if (chunk == null) {
                    val playingTrack = current ?: continue
                    val head = playingTrack.playbackHeadPosition.toLong()
                    stalled = if (head == lastHead) stalled + 1 else 0
                    lastHead = head
                    when (PlaybackTail.onIdle(head, written, stalled)) {
                        TailAction.WAIT -> Unit
                        TailAction.PAD -> written += pad(playingTrack)
                        TailAction.FINISH -> {
                            drop(playingTrack)
                            current = null
                            written = 0
                            lastHead = -1
                            stalled = 0
                            finished(now)
                        }
                    }
                    continue
                }
                if (chunk.generation != now) continue
                val target =
                    current ?: newTrack()?.also {
                        current = it
                        currentGeneration = now
                        written = 0
                        lastHead = -1
                    } ?: continue
                if (target.playState != AudioTrack.PLAYSTATE_PLAYING) target.play()
                target.write(chunk.pcm, 0, chunk.pcm.size)
                written += chunk.pcm.size / BYTES_PER_FRAME
                stalled = 0
            }
        } catch (e: InterruptedException) {
            // Released.
        } finally {
            current?.let(::drop)
        }
    }

    /**
     * A track starts only once its buffer is full, so a short tail (or the
     * first words, when the next chunk is late) would wait forever. Silence
     * fills the buffer and the tail plays; stopping the track instead left
     * later chunks unplayed on some phones (HyperOS) and Alesle stuck speaking.
     */
    private fun pad(track: AudioTrack): Long {
        val silence = ByteArray(track.bufferSizeInFrames.coerceAtLeast(1) * BYTES_PER_FRAME)
        val bytes = track.write(silence, 0, silence.size, AudioTrack.WRITE_NON_BLOCKING)
        return if (bytes > 0) bytes / BYTES_PER_FRAME.toLong() else 0
    }

    private fun finished(at: Int) {
        synchronized(this) {
            if (at != generation || queue.isNotEmpty() || !active) return
            active = false
            speaking(false)
        }
        onDrained?.invoke()
    }

    private fun drop(old: AudioTrack) {
        if (track === old) track = null
        runCatching {
            old.pause()
            old.flush()
        }
        old.release()
    }

    private fun newTrack(): AudioTrack? {
        val min = AudioTrack.getMinBufferSize(SAMPLE_RATE, AudioFormat.CHANNEL_OUT_MONO, AudioFormat.ENCODING_PCM_16BIT)
        if (min <= 0) return null
        val created =
            try {
                AudioTrack
                    .Builder()
                    .setAudioAttributes(
                        AudioAttributes
                            .Builder()
                            .setUsage(AudioAttributes.USAGE_ASSISTANT)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                            .build(),
                    ).setAudioFormat(
                        AudioFormat
                            .Builder()
                            .setSampleRate(SAMPLE_RATE)
                            .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                            .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                            .build(),
                    ).setBufferSizeInBytes(maxOf(min, SAMPLE_RATE / 5 * BYTES_PER_FRAME))
                    .setTransferMode(AudioTrack.MODE_STREAM)
                    .build()
            } catch (e: UnsupportedOperationException) {
                return null
            } catch (e: IllegalArgumentException) {
                return null
            }
        if (created.state != AudioTrack.STATE_INITIALIZED) {
            created.release()
            return null
        }
        track = created
        return created
    }

    companion object {
        const val SAMPLE_RATE = 24_000
        private const val BYTES_PER_FRAME = 2
        private const val POLL_MS = 40L
    }
}

enum class TailAction { WAIT, PAD, FINISH }

/** What the player does when no chunk came in a poll; pure, so it is tested without a speaker. */
object PlaybackTail {
    /** 120 ms without progress: the tail sits below the start threshold. */
    const val STALL_POLLS = 3

    /** 2 s without progress even after the silence: give the turn up, never stay "speaking". */
    const val GIVE_UP_POLLS = 50

    fun onIdle(
        head: Long,
        written: Long,
        stalledPolls: Int,
    ): TailAction =
        when {
            head >= written || stalledPolls >= GIVE_UP_POLLS -> TailAction.FINISH
            stalledPolls == STALL_POLLS -> TailAction.PAD
            else -> TailAction.WAIT
        }
}
