package com.alesle.ai.listen

import org.junit.After
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.math.PI
import kotlin.math.sin

class HandsFreeTest {
    @get:Rule
    val folder = TemporaryFolder()

    @After
    fun tearDown() {
        HandsFree.update(ListenState(active = false, muted = false))
        HandsFree.setSpeaking(false, now = 0)
    }

    @Test
    fun `wav files round-trip and other formats are refused`() {
        val pcm = ShortArray(1_000) { (it * 31 % 2_000 - 1_000).toShort() }
        val file = folder.newFile("a.wav")
        Wav.write(file, pcm)
        assertEquals(44L + 2_000L, file.length())
        assertArrayEquals(pcm, Wav.read(file))
        val text = folder.newFile("b.wav").apply { writeText("not a wav file at all, just some words to fill it up") }
        assertNull(Wav.read(text))
        // 8-bit stereo: a WAV, but not ours.
        val other = folder.newFile("c.wav")
        Wav.write(other, pcm)
        val bytes = other.readBytes()
        bytes[22] = 2
        bytes[34] = 8
        other.writeBytes(bytes)
        assertNull(Wav.read(other))
    }

    @Test
    fun `quiet while muted, while Alesle speaks, and a moment after`() {
        assertFalse(HandsFree.isQuiet(now = 1_000))
        HandsFree.update(ListenState(active = true, muted = true))
        assertTrue(HandsFree.isQuiet(now = 1_000))
        HandsFree.update(ListenState(active = true, muted = false))
        HandsFree.setSpeaking(true, now = 1_000)
        assertTrue(HandsFree.isQuiet(now = 5_000))
        HandsFree.setSpeaking(false, now = 5_000)
        assertTrue(HandsFree.isQuiet(now = 5_000 + HandsFree.ECHO_TAIL_MS - 1))
        assertFalse(HandsFree.isQuiet(now = 5_000 + HandsFree.ECHO_TAIL_MS))
    }

    @Test
    fun `listeners hear state changes and utterances until closed`() {
        val states = mutableListOf<ListenState>()
        val paths = mutableListOf<String>()
        val a = HandsFree.onState { states += it }
        val b = HandsFree.onUtterance { paths += it }
        HandsFree.update(ListenState(active = true, muted = false))
        HandsFree.update(ListenState(active = true, muted = false))
        HandsFree.deliver("/cache/u.wav")
        a.close()
        b.close()
        HandsFree.update(ListenState(active = false, muted = false))
        HandsFree.deliver("/cache/v.wav")
        assertEquals(listOf(ListenState(active = true, muted = false)), states)
        assertEquals(listOf("/cache/u.wav"), paths)
    }

    @Test
    fun `the engine hears injected speech, drops it while quiet, and stops`() {
        val got = CountDownLatch(1)
        var quiet = false
        val source = SilentSource()
        val heard = mutableListOf<ShortArray>()
        val engine =
            HandsFreeEngine(
                openSource = { source },
                quiet = { quiet },
                onUtterance = {
                    heard += it
                    got.countDown()
                },
            )
        assertTrue(engine.start())
        assertTrue(engine.start())
        quiet = true
        engine.inject(speech(800))
        Thread.sleep(50)
        quiet = false
        engine.inject(speech(800) + ShortArray(16_000))
        assertTrue(got.await(5, TimeUnit.SECONDS))
        engine.stop()
        assertFalse(engine.isRunning)
        assertEquals(1, heard.size)
        assertTrue(source.closed.await(2, TimeUnit.SECONDS))
    }

    @Test
    fun `no microphone, no engine, and a microphone taken for good is reported`() {
        assertFalse(HandsFreeEngine(openSource = { null }, quiet = { false }, onUtterance = {}).start())
        val lost = CountDownLatch(1)
        val gone =
            object : PcmSource {
                override fun read(frame: ShortArray) = -1

                override fun close() = Unit
            }
        val engine = HandsFreeEngine({ gone }, { false }, {}, onSourceLost = { lost.countDown() }, allowed = { false }, reopenMs = 10)
        assertTrue(engine.start())
        assertTrue(lost.await(2, TimeUnit.SECONDS))
        engine.stop()
    }

    @Test
    fun `a microphone taken by another app pauses listening, which comes back by itself`() {
        val pauses = java.util.concurrent.LinkedBlockingQueue<Boolean>()
        var lost = false
        var opens = 0
        val taken =
            object : PcmSource {
                override fun read(frame: ShortArray) = -1

                override fun close() = Unit
            }
        val engine =
            HandsFreeEngine(
                openSource = {
                    opens++
                    when (opens) {
                        1 -> taken
                        2 -> null // still busy
                        else -> SilentSource()
                    }
                },
                quiet = { false },
                onUtterance = {},
                onSourceLost = { lost = true },
                onPaused = { pauses.add(it) },
                reopenMs = 10,
            )
        assertTrue(engine.start())
        assertEquals(true, pauses.poll(2, TimeUnit.SECONDS))
        assertEquals(false, pauses.poll(2, TimeUnit.SECONDS))
        assertEquals(3, opens)
        assertFalse(lost)
        assertTrue(engine.isRunning)
        engine.stop()
    }

    private fun speech(ms: Int): ShortArray = ShortArray(ms * 16) { i -> (6_000 * sin(2 * PI * 220 * i / 16_000)).toInt().toShort() }

    /** A microphone in a silent room, paced like the real one. */
    private class SilentSource : PcmSource {
        val closed = CountDownLatch(1)

        override fun read(frame: ShortArray): Int {
            Thread.sleep(1)
            frame.fill(0)
            return frame.size
        }

        override fun close() = closed.countDown()
    }
}
