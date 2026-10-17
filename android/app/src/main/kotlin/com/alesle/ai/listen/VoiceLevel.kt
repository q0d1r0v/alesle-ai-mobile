package com.alesle.ai.listen

import kotlin.math.log10
import kotlin.math.sqrt

/**
 * How loud the microphone and Alesle's own voice are right now, 0..1, so the
 * orbs move with the voice (design: Gemini Live). Only a number is kept,
 * never audio. Written by the listening thread and the player's thread,
 * read by whoever draws.
 */
object VoiceLevel {
    private val micMeter = Meter()
    private val voiceMeter = Meter()

    /** The user's side: what the microphone hears (0 while muted). */
    @Volatile
    var mic = 0f
        private set

    /** Alesle's side: the reply being played. */
    @Volatile
    var voice = 0f
        private set

    fun hearMic(frame: ShortArray) {
        mic = synchronized(micMeter) { micMeter.next(loudness(frame)) }
    }

    fun quietMic() {
        mic = synchronized(micMeter) { micMeter.reset() }
    }

    /** One chunk of the reply, as 16-bit little-endian PCM. */
    fun hearVoice(pcm: ByteArray) {
        val samples = ShortArray(pcm.size / 2) { i -> ((pcm[2 * i].toInt() and 0xFF) or (pcm[2 * i + 1].toInt() shl 8)).toShort() }
        voice = synchronized(voiceMeter) { voiceMeter.next(loudness(samples)) }
    }

    fun quietVoice() {
        voice = synchronized(voiceMeter) { voiceMeter.reset() }
    }

    /** The louder side, for a single number. */
    val level: Float get() = maxOf(mic, voice)

    /** RMS of [samples] on a speech scale: a quiet room is 0, close speech near 1. */
    fun loudness(samples: ShortArray): Float {
        if (samples.isEmpty()) return 0f
        var sum = 0.0
        for (sample in samples) sum += sample.toDouble() * sample
        val rms = sqrt(sum / samples.size) / Short.MAX_VALUE
        if (rms <= 0.0) return 0f
        val db = 20 * log10(rms)
        return ((db - FLOOR_DB) / (CEILING_DB - FLOOR_DB)).toFloat().coerceIn(0f, 1f)
    }

    /** Rises at once with the voice, falls back gently, so the orb does not flicker. */
    class Meter {
        private var value = 0f

        fun next(loudness: Float): Float {
            val rate = if (loudness > value) ATTACK else RELEASE
            value += (loudness - value) * rate
            return value
        }

        fun reset(): Float {
            value = 0f
            return 0f
        }
    }

    private const val FLOOR_DB = -50.0
    private const val CEILING_DB = -10.0
    private const val ATTACK = 0.6f
    private const val RELEASE = 0.08f
}
