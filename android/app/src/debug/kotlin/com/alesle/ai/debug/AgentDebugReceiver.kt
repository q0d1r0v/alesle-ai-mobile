package com.alesle.ai.debug

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.alesle.ai.agent.AlesleAccessibilityService
import com.alesle.ai.agent.debug.DebugCommands
import com.alesle.ai.agent.generated.TaskRequest
import com.alesle.ai.agent.service.AgentForegroundService
import com.alesle.ai.agent.service.StopRequests
import com.alesle.ai.agent.task.AgentTaskController
import org.json.JSONObject
import kotlin.concurrent.thread

/**
 * Debug builds only: drives the agent runtime from a computer over adb. The
 * answer comes back as the broadcast's result data, printed by
 * `am broadcast`; nothing is written to disk or logs (SOW 03 A8).
 *
 * ```
 * adb shell am broadcast -n com.alesle.ai/.debug.AgentDebugReceiver --es cmd snapshot
 * adb shell am broadcast -n com.alesle.ai/.debug.AgentDebugReceiver --es cmd action \
 *     --es json "'{\"type\":\"tap\",\"nodeId\":4}'"
 * adb shell am broadcast -n com.alesle.ai/.debug.AgentDebugReceiver --es cmd task_start \
 *     --es step "'Budilnik 7:30'" --es url http://127.0.0.1:3000 --es token <DEV_AUTH_TOKEN> \
 *     [--es locale en] [--ez confirm false]
 * ```
 *
 * Commands: `snapshot`, `action`, `task_start`, `task_stop`, `fgs_step`, `status`.
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
        val url = intent.getStringExtra("url")
        val token = intent.getStringExtra("token")
        // --ez confirm false: a 3 s countdown instead of a question (the eval runs unattended).
        val confirm = intent.getBooleanExtra("confirm", true)
        val locale = intent.getStringExtra("locale") ?: "uz"
        val app = context.applicationContext
        thread(name = "alesle-debug") {
            val answer =
                try {
                    handle(app, cmd, json, step, Server(url, token, locale, confirm))
                } catch (e: RuntimeException) {
                    // A debug tool should report a crash, not take the app down with it.
                    error("exception:${e.javaClass.simpleName}")
                }
            pending.resultData = answer.toString()
            pending.finish()
        }
    }

    private fun handle(
        context: Context,
        cmd: String?,
        json: String?,
        step: String?,
        server: Server,
    ): JSONObject {
        if (stopHandle == null) stopHandle = StopRequests.register { stopRequests++ }
        val tasks = AgentTaskController.get(context)
        return when (cmd) {
            "snapshot" -> DebugCommands.shared.snapshot()
            "action" -> DebugCommands.shared.execute(json ?: return error("missing_json"))
            "task_start" -> {
                val request =
                    TaskRequest(
                        command = step.orEmpty(),
                        apiBaseUrl = server.url ?: return error("missing_url"),
                        accessToken = server.token ?: return error("missing_token"),
                        locale = server.locale,
                        confirmEverySensitiveAction = server.confirm,
                    )
                val result = tasks.start(request)
                JSONObject().put("started", result.started).put("reason", result.reason)
            }
            "task_stop" -> {
                tasks.stop()
                JSONObject().put("status", "ok")
            }
            "fgs_step" -> {
                AgentForegroundService.updateStep(context, step)
                JSONObject().put("status", "ok")
            }
            "status" ->
                JSONObject()
                    .put("accessibility", AlesleAccessibilityService.instance != null)
                    .put("taskRunning", tasks.isRunning)
                    .put("fgsRunning", AgentForegroundService.running)
                    .put("stopRequests", stopRequests)
                    .put("lastReply", tasks.lastFinished?.text)
            else -> error("unknown_cmd")
        }
    }

    private fun error(reason: String) = JSONObject().put("status", "error").put("reason", reason)

    private data class Server(
        val url: String?,
        val token: String?,
        val locale: String,
        val confirm: Boolean,
    )

    private companion object {
        /** How often "To'xtatish" was pressed since the first debug command. */
        @Volatile
        var stopRequests = 0

        var stopHandle: AutoCloseable? = null
    }
}
