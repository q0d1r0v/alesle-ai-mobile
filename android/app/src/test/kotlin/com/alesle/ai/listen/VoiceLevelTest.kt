package com.alesle.ai.listen

import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.math.PI
import kotlin.math.sin

class VoiceLevelTest {
    @After
    fun tearDown() {
        VoiceLevel.quietMic()
        VoiceLevel.quietVoice()
    }

    @Test
    fun `silence is zero and close speech is loud`() {
        assertEquals(0f, VoiceLevel.loudness(ShortArray(320)), 0f)
        assertEquals(0f, VoiceLevel.loudness(ShortArray(0)), 0f)
        assertTrue(VoiceLevel.loudness(tone(30)) < 0.15f)
        assertTrue(VoiceLevel.loudness(tone(8_000)) > 0.8f)
        assertEquals(1f, VoiceLevel.loudness(tone(32_000)), 0f)
    }

    @Test
    fun `the meter rises at once and falls back gently`() {
        val meter = VoiceLevel.Meter()
        val up = meter.next(1f)
        assertTrue(up >= 0.6f)
        val down = meter.next(0f)
        assertTrue(down in 0.4f..up)
        assertEquals(0f, meter.reset(), 0f)
    }

    @Test
    fun `the microphone and Alesle's voice are kept apart, the louder one wins`() {
        VoiceLevel.hearMic(tone(8_000))
        assertTrue(VoiceLevel.mic > 0.4f)
        assertEquals(0f, VoiceLevel.voice, 0f)
        val pcm = ByteArray(640)
        tone(8_000).forEachIndexed { i, s ->
            pcm[2 * i] = (s.toInt() and 0xFF).toByte()
            pcm[2 * i + 1] = (s.toInt() shr 8).toByte()
        }
        VoiceLevel.quietMic()
        VoiceLevel.hearVoice(pcm)
        assertTrue(VoiceLevel.voice > 0.4f)
        assertEquals(VoiceLevel.voice, VoiceLevel.level, 0f)
        VoiceLevel.quietVoice()
        assertEquals(0f, VoiceLevel.level, 0f)
    }

    private fun tone(amplitude: Int): ShortArray = ShortArray(320) { i -> (amplitude * sin(2 * PI * 220 * i / 16_000)).toInt().toShort() }
}
