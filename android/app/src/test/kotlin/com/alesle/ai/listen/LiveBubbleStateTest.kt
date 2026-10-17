package com.alesle.ai.listen

import com.alesle.ai.agent.generated.LivePhase
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class LiveBubbleStateTest {
    private val base = BubbleInputs(listening = true, muted = false, phase = LivePhase.LISTENING, appVisible = false, taskRunning = false)

    @Test
    fun `shows in other apps while hands-free listens, with the conversation's look`() {
        assertEquals(BubbleLook.LISTENING, LiveBubbleState.look(base))
        assertEquals(BubbleLook.HEARING, LiveBubbleState.look(base.copy(phase = LivePhase.HEARING)))
        assertEquals(BubbleLook.THINKING, LiveBubbleState.look(base.copy(phase = LivePhase.THINKING)))
        assertEquals(BubbleLook.SPEAKING, LiveBubbleState.look(base.copy(phase = LivePhase.SPEAKING)))
        assertEquals(BubbleLook.CONNECTING, LiveBubbleState.look(base.copy(phase = LivePhase.CONNECTING)))
        assertEquals(BubbleLook.CONNECTING, LiveBubbleState.look(base.copy(phase = LivePhase.UNAUTHORIZED)))
        assertEquals(BubbleLook.LISTENING, LiveBubbleState.look(base.copy(phase = LivePhase.FALLBACK)))
        assertEquals(BubbleLook.LISTENING, LiveBubbleState.look(base.copy(phase = null)))
        assertEquals(BubbleLook.MUTED, LiveBubbleState.look(base.copy(muted = true, phase = LivePhase.SPEAKING)))
        assertEquals(BubbleLook.PAUSED, LiveBubbleState.look(base.copy(paused = true, phase = LivePhase.HEARING)))
        assertEquals(BubbleLook.MUTED, LiveBubbleState.look(base.copy(muted = true, paused = true)))
    }

    @Test
    fun `hides when off, in Alesle itself, while a task works the screen, or once the plan is used up`() {
        assertNull(LiveBubbleState.look(base.copy(listening = false)))
        assertNull(LiveBubbleState.look(base.copy(appVisible = true)))
        assertNull(LiveBubbleState.look(base.copy(taskRunning = true)))
        assertNull(LiveBubbleState.look(base.copy(phase = LivePhase.LIMIT_REACHED)))
    }

    @Test
    fun `a dropped bubble settles at the nearer edge, inside the screen`() {
        assertEquals(8, LiveBubbleState.snapX(x = 100, size = 150, screenWidth = 1080, margin = 8))
        assertEquals(1080 - 150 - 8, LiveBubbleState.snapX(x = 700, size = 150, screenWidth = 1080, margin = 8))
        assertEquals(8, LiveBubbleState.clampY(y = -40, size = 150, screenHeight = 2400, margin = 8))
        assertEquals(2400 - 150 - 8, LiveBubbleState.clampY(y = 3000, size = 150, screenHeight = 2400, margin = 8))
        assertEquals(500, LiveBubbleState.clampY(y = 500, size = 150, screenHeight = 2400, margin = 8))
    }
}
