package com.alesle.ai.agent.loop

import com.alesle.ai.agent.AgentRuntime
import com.alesle.ai.agent.action.ActionExecutor
import com.alesle.ai.agent.action.ActionResult
import com.alesle.ai.agent.protocol.DecodedAction
import com.alesle.ai.agent.snapshot.CapturedScreen

/** [LoopDevice] on the connected AccessibilityService; every call finds it anew, it may come and go. */
class RuntimeLoopDevice(
    private val runtime: () -> AgentRuntime?,
    private val lastEventAt: () -> Long,
    private val now: () -> Long,
    private val sleep: (Long) -> Unit = Thread::sleep,
) : LoopDevice {
    override fun capture(): CapturedScreen? = runtime()?.capture()

    override fun execute(
        action: DecodedAction,
        screen: CapturedScreen?,
    ): ActionResult {
        val connected = runtime() ?: return ActionResult.error(ACCESSIBILITY_OFF)
        return when (action) {
            is DecodedAction.Intent -> connected.intentLauncher?.execute(action.action) ?: ActionResult.error(ACCESSIBILITY_OFF)
            is DecodedAction.Screen -> {
                val device = connected.deviceControl ?: return ActionResult.error(ACCESSIBILITY_OFF)
                val target = screen ?: device.capture() ?: return ActionResult.notFound("no_window")
                ActionExecutor(device).execute(action.action, target)
            }
        }
    }

    /**
     * Waits until no accessibility event has arrived for [QUIET_MS], at most
     * [MAX_SETTLE_MS]. A screen still loading reads slowly and changes under
     * the next decision (device test, 2026-10-16).
     */
    override fun settle() {
        val started = now()
        sleep(FIRST_PAUSE_MS)
        while (now() - started < MAX_SETTLE_MS) {
            val quietFor = now() - lastEventAt()
            if (quietFor >= QUIET_MS) return
            sleep(minOf(POLL_MS, QUIET_MS - quietFor))
        }
    }

    companion object {
        const val ACCESSIBILITY_OFF = "accessibility_off"
        const val FIRST_PAUSE_MS = 150L
        const val QUIET_MS = 400L
        const val POLL_MS = 100L
        const val MAX_SETTLE_MS = 3_000L
    }
}
