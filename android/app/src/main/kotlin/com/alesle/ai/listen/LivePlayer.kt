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
                    if (head >= written) {
                        drop(playingTrack)
                        current = null
                        written = 0
                        finished(now)
                        continue
                    }
                    // A short tail can sit below the start threshold: stop() plays it out.
                    stalled = if (head == lastHead) stalled + 1 else 0
                    lastHead = head
                    if (stalled == STALL_POLLS) runCatching { playingTrack.stop() }
                    continue
                }
                if (chunk.generation != now) continue
                val target =
                    current ?: newTrack()?.also {
                        current = it
                        currentGeneration = now
                        written = 0
                        it.play()
                    } ?: continue
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
        private const val STALL_POLLS = 3
    }
}
