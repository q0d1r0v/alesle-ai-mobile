package com.alesle.ai.agent.debug

import com.alesle.ai.agent.AgentRuntime
import com.alesle.ai.agent.AlesleAccessibilityService
import com.alesle.ai.agent.action.ActionExecutor
import com.alesle.ai.agent.protocol.ActionDecodeException
import com.alesle.ai.agent.protocol.ActionJson
import com.alesle.ai.agent.protocol.DecodedAction
import com.alesle.ai.agent.snapshot.CapturedScreen
import org.json.JSONObject

/**
 * Snapshot and single actions for developer tools (the debug screen and the
 * adb receiver), so the runtime can be tried before the agent loop exists.
 * Callers gate it to debug builds. Answers stay in memory; nothing is
 * written to disk or logs (SOW 03 A8).
 *
 * Blocking: call it off the main thread.
 */
class DebugCommands(
    private val runtime: () -> AgentRuntime?,
    private val nanoTime: () -> Long = System::nanoTime,
) {
    /** The screen node ids refer to, as they will for the agent loop. */
    @Volatile
    private var lastScreen: CapturedScreen? = null

    /** `{"captureMs":…,"snapshot":{…}}`, or an error. */
    fun snapshot(): JSONObject {
        val runtime = runtime() ?: return error("accessibility_off")
        val started = nanoTime()
        val screen = runtime.capture() ?: return error("no_window")
        val captureMs = (nanoTime() - started) / NANOS_PER_MS
        lastScreen = screen
        return JSONObject().put("captureMs", captureMs).put("snapshot", screen.snapshot.toJson())
    }

    /** Runs one ActionJson action; the result in the same wire format. */
    fun execute(actionJson: String): JSONObject {
        val decoded =
            try {
                ActionJson.decode(actionJson)
            } catch (e: ActionDecodeException) {
                return error(e.reason)
            }
        val runtime = runtime() ?: return error("accessibility_off")
        val result =
            when (decoded) {
                is DecodedAction.Intent -> runtime.intentLauncher?.execute(decoded.action) ?: return error("accessibility_off")
                is DecodedAction.Screen -> {
                    val device = runtime.deviceControl ?: return error("accessibility_off")
                    val screen = lastScreen ?: device.capture() ?: return error("no_window")
                    ActionExecutor(device).execute(decoded.action, screen)
                }
                is DecodedAction.WaitForUser -> return error("loop_only")
            }
        return ActionJson.encode(result)
    }

    private fun error(reason: String) = JSONObject().put("status", "error").put("reason", reason)

    companion object {
        private const val NANOS_PER_MS = 1_000_000L

        /** One per process, so the debug screen and adb share the last snapshot. */
        val shared: DebugCommands by lazy { DebugCommands({ AlesleAccessibilityService.instance }) }
    }
}
