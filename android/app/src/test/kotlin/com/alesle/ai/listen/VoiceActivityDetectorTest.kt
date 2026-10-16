package com.alesle.ai.listen

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.math.PI
import kotlin.math.sin
import kotlin.random.Random

class VoiceActivityDetectorTest {
    private val heard = mutableListOf<ShortArray>()
    private val detector = VoiceActivityDetector({ heard += it })
    private val random = Random(7)

    /** [ms] of a voice-like tone at [amplitude], in 20 ms frames. */
    private fun tone(
        ms: Int,
        amplitude: Double = 6_000.0,
    ): List<ShortArray> = frames(ms) { i -> (amplitude * sin(2 * PI * 220 * i / VoiceActivityDetector.SAMPLE_RATE)).toInt() }

    /** [ms] of room noise at about [level] RMS. */
    private fun noise(
        ms: Int,
        level: Int = 120,
    ): List<ShortArray> = frames(ms) { random.nextInt(-level * 17 / 10, level * 17 / 10) }

    private fun frames(
        ms: Int,
        sample: (Int) -> Int,
    ): List<ShortArray> {
        var n = 0
        return List(ms / 20) {
            ShortArray(VoiceActivityDetector.FRAME_SAMPLES) { sample(n++).coerceIn(-32_768, 32_767).toShort() }
        }
    }

    private fun feed(frames: List<ShortArray>) = frames.forEach(detector::accept)

    @Test
    fun `a sentence between pauses is one utterance, with the audio just before it`() {
        feed(noise(1_000))
        feed(tone(1_200))
        assertTrue(detector.inSpeech)
        feed(noise(1_000))
        assertEquals(1, heard.size)
        // Preroll (≥ 300 ms) + speech + the pause that ended it.
        val ms = heard.single().size / 16
        assertTrue("utterance was $ms ms", ms in 1_500..2_600)
        assertFalse(detector.inSpeech)
    }

    @Test
    fun `steady room noise and short clicks are not words`() {
        feed(noise(3_000, level = 300))
        feed(tone(120))
        feed(noise(1_500))
        assertTrue(heard.isEmpty())
    }

    @Test
    fun `a one-word answer is words`() {
        // "Ha", "Стоп": about 300 ms of voice.
        feed(noise(800))
        feed(tone(320))
        feed(noise(1_200))
        assertEquals(1, heard.size)
    }

    @Test
    fun `the floor follows a louder room, so its hum does not start an utterance`() {
        // A fan at ~200 RMS for a while, then speech well above it.
        feed(noise(4_000, level = 200))
        assertTrue(heard.isEmpty())
        feed(tone(800, amplitude = 4_000.0))
        feed(noise(1_000, level = 200))
        assertEquals(1, heard.size)
    }

    @Test
    fun `two sentences with a pause between are two utterances`() {
        feed(noise(500))
        feed(tone(700))
        feed(noise(1_200))
        feed(tone(700))
        feed(noise(1_200))
        assertEquals(2, heard.size)
    }

    @Test
    fun `endless talk is cut at the longest utterance`() {
        feed(noise(500))
        feed(tone(16_000))
        assertEquals(1, heard.size)
        assertTrue(heard.single().size <= VoiceActivityDetector.Tuning().maxFrames * VoiceActivityDetector.FRAME_SAMPLES)
    }

    @Test
    fun `reset drops what was being collected`() {
        feed(noise(500))
        feed(tone(600))
        detector.reset()
        feed(noise(1_000))
        assertTrue(heard.isEmpty())
    }

    @Test
    fun `rms of silence and of an empty frame is zero`() {
        assertEquals(0.0, VoiceActivityDetector.rms(ShortArray(0)), 0.0)
        assertEquals(0.0, VoiceActivityDetector.rms(ShortArray(320)), 0.0)
        assertEquals(1_000.0, VoiceActivityDetector.rms(ShortArray(4) { 1_000 }), 0.001)
    }
}
