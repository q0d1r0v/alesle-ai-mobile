package com.alesle.ai.listen

import org.junit.Assert.assertEquals
import org.junit.Test

class PlaybackTailTest {
    @Test
    fun `finishes once everything written has played`() {
        assertEquals(TailAction.FINISH, PlaybackTail.onIdle(head = 4_800, written = 4_800, stalledPolls = 0))
        assertEquals(TailAction.FINISH, PlaybackTail.onIdle(head = 5_000, written = 4_800, stalledPolls = 2))
    }

    @Test
    fun `waits while the voice is still playing`() {
        assertEquals(TailAction.WAIT, PlaybackTail.onIdle(head = 1_000, written = 4_800, stalledPolls = 0))
        assertEquals(TailAction.WAIT, PlaybackTail.onIdle(head = 1_000, written = 4_800, stalledPolls = 2))
    }

    @Test
    fun `pads a stalled tail with silence once, instead of stopping the track`() {
        assertEquals(TailAction.PAD, PlaybackTail.onIdle(head = 0, written = 3_120, stalledPolls = PlaybackTail.STALL_POLLS))
        assertEquals(TailAction.WAIT, PlaybackTail.onIdle(head = 0, written = 3_120, stalledPolls = PlaybackTail.STALL_POLLS + 1))
    }

    @Test
    fun `gives the turn up when nothing plays even after the silence, so Alesle never stays speaking`() {
        assertEquals(TailAction.FINISH, PlaybackTail.onIdle(head = 0, written = 7_920, stalledPolls = PlaybackTail.GIVE_UP_POLLS))
    }
}
