package com.alesle.ai.listen

import kotlin.math.max
import kotlin.math.sqrt

/**
 * Cuts continuous microphone audio into utterances (hands-free, SOW 04 §4.3).
 * Energy-based with an adaptive noise floor: a frame is speech when its RMS
 * stands well above the room's own level. Speech starts after a few speech
 * frames in a row, ends after a pause, and keeps a little audio from before
 * it began so the first syllable is not lost.
 *
 * Feed 16 kHz mono PCM16 frames of [FRAME_SAMPLES]; pure Kotlin, so every
 * rule is unit-tested on the JVM. Not thread-safe: one capture thread owns it.
 */
class VoiceActivityDetector(
    private val onUtterance: (ShortArray) -> Unit,
    private val tuning: Tuning = Tuning(),
    /** Live voice: speech as it comes, once it is clearly words; null for whole utterances only. */
    private val stream: SpeechStream? = null,
    /** True while Alesle speaks: only louder, closer speech counts (barge-in, not its own echo). */
    private val strict: () -> Boolean = { false },
) {
    data class Tuning(
        /** Speech must stand this many times above the noise floor. */
        val speechFactor: Double = 3.0,
        /** RMS below this is silence whatever the floor (a dead-quiet room). */
        val minSpeechRms: Double = 350.0,
        /** Speech frames in a row before an utterance starts (~100 ms). */
        val onsetFrames: Int = 5,
        /** Quiet frames in a row that end an utterance (~600 ms): quick to answer, long enough for a breath. */
        val hangoverFrames: Int = 30,
        /** Audio kept from before the start (~300 ms). */
        val prerollFrames: Int = 15,
        /** Shorter speech is a click, not words (~200 ms): "Ha", "Стоп" are ~300 ms. */
        val minSpeechFrames: Int = 10,
        /** A longer utterance is cut and sent as it is (~15 s). */
        val maxFrames: Int = 750,
        /** How fast the floor follows the room while nobody speaks. */
        val floorAdapt: Double = 0.05,
        /** While Alesle speaks, speech must be this much louder to count. */
        val bargeInFactor: Double = 2.5,
    )

    private var floor = tuning.minSpeechRms / tuning.speechFactor
    private val preroll = ArrayDeque<ShortArray>()
    private val utterance = ArrayList<ShortArray>()
    private var speaking = false
    private var run = 0
    private var quiet = 0
    private var speechFrames = 0

    /** The stream was told this utterance started. */
    private var announced = false

    /** True while an utterance is being collected. */
    val inSpeech: Boolean get() = speaking

    fun accept(frame: ShortArray) {
        val rms = rms(frame)
        val scale = if (strict()) tuning.bargeInFactor else 1.0
        val loud = rms >= max(tuning.minSpeechRms, floor * tuning.speechFactor) * scale
        if (!speaking) {
            preroll.addLast(frame)
            if (preroll.size > tuning.prerollFrames + tuning.onsetFrames) preroll.removeFirst()
            run = if (loud) run + 1 else 0
            if (!loud) floor += (rms - floor) * tuning.floorAdapt
            if (run >= tuning.onsetFrames) {
                speaking = true
                utterance.addAll(preroll)
                preroll.clear()
                speechFrames = run
                quiet = 0
            }
            return
        }
        utterance.add(frame)
        if (loud) {
            speechFrames++
            quiet = 0
        } else {
            quiet++
        }
        announce(frame)
        if (quiet >= tuning.hangoverFrames || utterance.size >= tuning.maxFrames) end()
    }

    /** Clicks never reach the stream: it hears an utterance only once it has enough speech in it. */
    private fun announce(frame: ShortArray) {
        val stream = stream ?: return
        if (announced) {
            stream.onSpeechFrame(frame)
            return
        }
        if (speechFrames < tuning.minSpeechFrames) return
        announced = true
        stream.onSpeechStart(utterance.toList())
    }

    /** Drops whatever was being collected (muted, or our own voice playing). */
    fun reset() {
        if (announced) stream?.onSpeechEnd(cancelled = true)
        announced = false
        preroll.clear()
        utterance.clear()
        speaking = false
        run = 0
        quiet = 0
        speechFrames = 0
    }

    private fun end() {
        val frames = utterance.toList()
        val words = speechFrames >= tuning.minSpeechFrames
        if (announced) stream?.onSpeechEnd(cancelled = false)
        announced = false
        reset()
        if (!words) return
        val pcm = ShortArray(frames.sumOf { it.size })
        var at = 0
        for (frame in frames) {
            frame.copyInto(pcm, at)
            at += frame.size
        }
        onUtterance(pcm)
    }

    /** Speech as it is heard: start (with what came just before), each frame, end. */
    interface SpeechStream {
        fun onSpeechStart(frames: List<ShortArray>)

        fun onSpeechFrame(frame: ShortArray)

        /** [cancelled]: cut off by mute, not ended by a pause. */
        fun onSpeechEnd(cancelled: Boolean)
    }

    companion object {
        const val SAMPLE_RATE = 16_000

        /** 20 ms at 16 kHz. */
        const val FRAME_SAMPLES = 320

        internal fun rms(frame: ShortArray): Double {
            if (frame.isEmpty()) return 0.0
            var sum = 0.0
            for (sample in frame) sum += sample.toDouble() * sample
            return sqrt(sum / frame.size)
        }
    }
}
