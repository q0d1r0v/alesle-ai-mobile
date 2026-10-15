package com.alesle.ai.debug

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.SystemClock
import com.alesle.ai.agent.AlesleAccessibilityService
import com.alesle.ai.agent.action.ActionExecutor
import com.alesle.ai.agent.protocol.ActionDecodeException
import com.alesle.ai.agent.protocol.ActionJson
import com.alesle.ai.agent.protocol.DecodedAction
import com.alesle.ai.agent.service.AgentForegroundService
import com.alesle.ai.agent.service.StopRequests
import com.alesle.ai.agent.snapshot.CapturedScreen
import org.json.JSONObject
import kotlin.concurrent.thread

/**
 * Debug builds only: drives the agent runtime from a computer over adb, so
 * snapshots and actions can be tried on a real phone before the agent loop
 * exists. The answer comes back as the broadcast's result data, printed by
 * `am broadcast`; nothing is written to disk or logs (SOW 03 A8).
 *
 * ```
 * adb shell am broadcast -n com.alesle.ai/.debug.AgentDebugReceiver --es cmd snapshot
 * adb shell am broadcast -n com.alesle.ai/.debug.AgentDebugReceiver --es cmd action \
 *     --es json "'{\"type\":\"tap\",\"nodeId\":4}'"
 * adb shell am broadcast -n com.alesle.ai/.debug.AgentDebugReceiver --es cmd fgs_start --es step "'Sinov'"
 * ```
 *
 * Commands: `snapshot`, `action`, `fgs_start`, `fgs_step`, `fgs_stop`, `status`.
 *
 * Guarded by the DUMP permission, which the adb shell holds and ordinary apps
 * cannot get.
 */
class AgentDebugReceiver : BroadcastReceiver() {
    override fun onReceive(
        context: Context,
        intent: Intent,
    ) {
        val pending = goAsync()
        val cmd = intent.getStringExtra("cmd")
        val json = intent.getStringExtra("json")
        val step = intent.getStringExtra("step")
        val app = context.applicationContext
        thread(name = "alesle-debug") {
            val answer =
                try {
                    service(app, cmd, step) ?: handle(cmd, json)
                } catch (e: ActionDecodeException) {
                    error(e.reason)
                } catch (e: RuntimeException) {
                    // A debug tool should report a crash, not take the app down with it.
                    error("exception:${e.javaClass.simpleName}")
                }
            pending.resultData = answer.toString()
            pending.finish()
        }
    }

    /** Foreground-service commands; null for anything else. */
    private fun service(
        context: Context,
        cmd: String?,
        step: String?,
    ): JSONObject? {
        if (stopHandle == null) stopHandle = StopRequests.register { stopRequests++ }
        return when (cmd) {
            "fgs_start" -> JSONObject().put("started", AgentForegroundService.start(context, step))
            "fgs_step" -> {
                AgentForegroundService.updateStep(context, step)
                JSONObject().put("status", "ok")
            }
            "fgs_stop" -> {
                AgentForegroundService.stop(context)
                JSONObject().put("status", "ok")
            }
            "status" ->
                JSONObject()
                    .put("accessibility", AlesleAccessibilityService.instance != null)
                    .put("fgsRunning", AgentForegroundService.running)
                    .put("stopRequests", stopRequests)
            else -> null
        }
    }

    private fun handle(
        cmd: String?,
        json: String?,
    ): JSONObject {
        val service = AlesleAccessibilityService.instance ?: return error("accessibility_off")
        return when (cmd) {
            "snapshot" -> {
                val started = SystemClock.elapsedRealtimeNanos()
                val screen = service.capture() ?: return error("no_window")
                val captureMs = (SystemClock.elapsedRealtimeNanos() - started) / NANOS_PER_MS
                lastScreen = screen
                JSONObject().put("captureMs", captureMs).put("snapshot", screen.snapshot.toJson())
            }
            "action" -> {
                val decoded = ActionJson.decode(json ?: return error("missing_json"))
                val result =
                    when (decoded) {
                        is DecodedAction.Intent ->
                            service.intentLauncher?.execute(decoded.action) ?: return error("accessibility_off")
                        is DecodedAction.Screen -> {
                            val device = service.deviceControl ?: return error("accessibility_off")
                            // Node ids refer to the last snapshot, as they will for the agent loop.
                            val screen = lastScreen ?: device.capture() ?: return error("no_window")
                            ActionExecutor(device).execute(decoded.action, screen)
                        }
                    }
                ActionJson.encode(result)
            }
            else -> error("unknown_cmd")
        }
    }

    private fun error(reason: String) = JSONObject().put("status", "error").put("reason", reason)

    private companion object {
        const val NANOS_PER_MS = 1_000_000L

        /** How often "To'xtatish" was pressed since the first debug command. */
        @Volatile
        var stopRequests = 0

        var stopHandle: AutoCloseable? = null

        /** The screen node ids refer to; lives only in memory. */
        @Volatile
        var lastScreen: CapturedScreen? = null
    }
}
