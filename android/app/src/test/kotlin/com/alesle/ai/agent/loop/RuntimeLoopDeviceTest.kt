package com.alesle.ai.agent.loop

import com.alesle.ai.agent.AgentRuntime
import com.alesle.ai.agent.action.ActionResult
import com.alesle.ai.agent.action.AgentAction
import com.alesle.ai.agent.action.DeviceControl
import com.alesle.ai.agent.action.Gesture
import com.alesle.ai.agent.action.GlobalAction
import com.alesle.ai.agent.intent.IntentAction
import com.alesle.ai.agent.intent.IntentLauncher
import com.alesle.ai.agent.protocol.DecodedAction
import com.alesle.ai.agent.snapshot.Bounds
import com.alesle.ai.agent.snapshot.CapturedScreen
import com.alesle.ai.agent.snapshot.Orientation
import com.alesle.ai.agent.snapshot.ScreenSnapshot
import io.mockk.every
import io.mockk.mockk
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test

class RuntimeLoopDeviceTest {
    private val screen =
        CapturedScreen(
            ScreenSnapshot("s", "p", null, "h", "uz", Orientation.PORTRAIT, emptyList(), keyboardVisible = false, truncated = false),
            emptyList(),
            Bounds(0, 0, 1080, 2400),
        )
    private val globals = mutableListOf<GlobalAction>()
    private val control =
        object : DeviceControl {
            var screenToCapture: CapturedScreen? = screen

            override fun capture() = screenToCapture

            override fun performGlobal(action: GlobalAction): Boolean {
                globals += action
                return true
            }

            override fun performGesture(gesture: Gesture) = true
        }
    private val launcher = mockk<IntentLauncher>()

    private fun runtime(
        control: DeviceControl? = this.control,
        launcher: IntentLauncher? = this.launcher,
    ) = object : AgentRuntime {
        override fun capture() = screen

        override val deviceControl = control
        override val intentLauncher = launcher
    }

    @Test
    fun `captures through the connected service`() {
        assertSame(screen, RuntimeLoopDevice({ runtime() }, { 0 }, { 0 }).capture())
        assertNull(RuntimeLoopDevice({ null }, { 0 }, { 0 }).capture())
    }

    @Test
    fun `runs screen actions and intents`() {
        val device = RuntimeLoopDevice({ runtime() }, { 0 }, { 0 })
        assertEquals(ActionResult.OK, device.execute(DecodedAction.Screen(AgentAction.Global(GlobalAction.HOME)), screen))
        assertEquals(listOf(GlobalAction.HOME), globals)

        // Without a previous capture it captures first.
        assertEquals(ActionResult.OK, device.execute(DecodedAction.Screen(AgentAction.Global(GlobalAction.BACK)), null))

        every { launcher.execute(IntentAction.WebSearch("ob-havo")) } returns ActionResult.notFound("no_app_for_intent")
        assertEquals(
            ActionResult.notFound("no_app_for_intent"),
            device.execute(DecodedAction.Intent(IntentAction.WebSearch("ob-havo")), screen),
        )
    }

    @Test
    fun `reports what is missing`() {
        val back = DecodedAction.Screen(AgentAction.Global(GlobalAction.BACK))
        val search = DecodedAction.Intent(IntentAction.WebSearch("x"))
        assertEquals(ActionResult.error("accessibility_off"), RuntimeLoopDevice({ null }, { 0 }, { 0 }).execute(back, screen))
        assertEquals(
            ActionResult.error("accessibility_off"),
            RuntimeLoopDevice({ runtime(control = null) }, { 0 }, { 0 }).execute(back, screen),
        )
        assertEquals(
            ActionResult.error("accessibility_off"),
            RuntimeLoopDevice({ runtime(launcher = null) }, { 0 }, { 0 }).execute(search, screen),
        )
        control.screenToCapture = null
        assertEquals(ActionResult.notFound("no_window"), RuntimeLoopDevice({ runtime() }, { 0 }, { 0 }).execute(back, null))
    }

    @Test
    fun `settles once the screen has been quiet`() {
        var clock = 1_000L
        val sleeps = mutableListOf<Long>()
        val lastEvent = 1_000L
        val device =
            RuntimeLoopDevice({ runtime() }, { lastEvent }, { clock }) { ms ->
                sleeps += ms
                clock += ms
            }
        device.settle()
        // 150 first, then 100 ms polls until 400 ms have passed since the last event.
        assertEquals(listOf(150L, 100L, 100L, 50L), sleeps)

        sleeps.clear()
        // Events keep coming: give up after the cap.
        val busy =
            RuntimeLoopDevice({ runtime() }, { clock }, { clock }) { ms ->
                sleeps += ms
                clock += ms
            }
        busy.settle()
        val waited = sleeps.sum()
        assertTrue(
            "waited $waited ms",
            waited >= RuntimeLoopDevice.MAX_SETTLE_MS && waited < RuntimeLoopDevice.MAX_SETTLE_MS + RuntimeLoopDevice.POLL_MS,
        )
    }
}
