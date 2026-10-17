package com.alesle.ai.listen

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

@RunWith(RobolectricTestRunner::class)
class LivePlayerTest {
    @Test
    fun `a short reply drains and stops speaking`() {
        val speaking = mutableListOf<Boolean>()
        val player = LivePlayer(speaking = { synchronized(speaking) { speaking += it } })
        val drained = CountDownLatch(1)
        player.onDrained = { drained.countDown() }

        player.play(ByteArray(LivePlayer.SAMPLE_RATE / 8 * 2))
        assertTrue(player.playing)

        assertTrue("never drained: Alesle would stay speaking", drained.await(5, TimeUnit.SECONDS))
        assertFalse(player.playing)
        synchronized(speaking) { assertTrue(speaking == listOf(true, false)) }
        player.release()
    }
}
