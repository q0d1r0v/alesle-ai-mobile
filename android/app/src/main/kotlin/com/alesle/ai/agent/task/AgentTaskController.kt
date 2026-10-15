package com.alesle.ai.agent.task

import android.content.Context
import com.alesle.ai.agent.AccessibilityStatus
import com.alesle.ai.agent.generated.StartTaskResult
import com.alesle.ai.agent.generated.StepEvent
import com.alesle.ai.agent.generated.StepEventKind
import com.alesle.ai.agent.service.AgentForegroundService
import com.alesle.ai.agent.service.StopRequests

/**
 * Owns the one running task: starts the foreground service with it, ends it
 * on a stop from the app or the notification, and reports each change to
 * [listener] (the Flutter UI, while it is attached).
 *
 * Sprint 1 has no agent loop yet, so a task runs until it is stopped; the
 * loop (Sprint 2) plugs in here and reports `step` and `finished`.
 */
class AgentTaskController(
    private val accessibilityEnabled: () -> Boolean,
    /** Starts the foreground service with the step text; false when Android refuses. */
    private val startService: (String?) -> Boolean,
    private val stopService: () -> Unit,
) {
    @Volatile
    var listener: ((StepEvent) -> Unit)? = null

    private var stopHandle: AutoCloseable? = null

    val isRunning: Boolean
        @Synchronized get() = stopHandle != null

    fun start(command: String): StartTaskResult {
        val text = command.trim()
        synchronized(this) {
            val refusal =
                when {
                    text.isEmpty() -> "empty_command"
                    stopHandle != null -> "already_running"
                    !accessibilityEnabled() -> "accessibility_off"
                    !startService(text) -> "background_start_refused"
                    else -> null
                }
            if (refusal != null) return StartTaskResult(started = false, reason = refusal)
            stopHandle = StopRequests.register(::stop)
        }
        emit(StepEvent(StepEventKind.STARTED, text))
        return StartTaskResult(started = true)
    }

    /** The user stopped the task; a no-op when none runs. */
    fun stop() {
        synchronized(this) {
            val handle = stopHandle ?: return
            handle.close()
            stopHandle = null
            stopService()
        }
        emit(StepEvent(StepEventKind.STOPPED))
    }

    private fun emit(event: StepEvent) {
        listener?.invoke(event)
    }

    companion object {
        @Volatile
        private var instance: AgentTaskController? = null

        /** One per process: a task outlives the activity that started it. */
        fun get(context: Context): AgentTaskController =
            instance ?: synchronized(this) {
                instance ?: run {
                    val app = context.applicationContext
                    AgentTaskController(
                        accessibilityEnabled = AccessibilityStatus(app)::isServiceEnabled,
                        startService = { step -> AgentForegroundService.start(app, step) },
                        stopService = { AgentForegroundService.stop(app) },
                    ).also { instance = it }
                }
            }
    }
}
