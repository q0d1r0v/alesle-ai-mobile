package com.alesle.ai.agent.task

import android.content.Context
import android.os.SystemClock
import com.alesle.ai.agent.AccessibilityStatus
import com.alesle.ai.agent.AlesleAccessibilityService
import com.alesle.ai.agent.generated.StartTaskResult
import com.alesle.ai.agent.generated.StepEvent
import com.alesle.ai.agent.generated.StepEventKind
import com.alesle.ai.agent.generated.TaskRequest
import com.alesle.ai.agent.loop.AgentLoop
import com.alesle.ai.agent.loop.ConfirmPolicy
import com.alesle.ai.agent.loop.HandlerLoopWorker
import com.alesle.ai.agent.loop.LoopEvent
import com.alesle.ai.agent.loop.LoopRequest
import com.alesle.ai.agent.loop.OkHttpLoopSocketFactory
import com.alesle.ai.agent.loop.RuntimeLoopDevice
import com.alesle.ai.agent.overlay.AgentOverlay
import com.alesle.ai.agent.service.AgentForegroundService
import com.alesle.ai.agent.service.StopRequests

/** A running task as the controller sees it: [AgentLoop] in production. */
interface TaskLoop {
    fun start()

    fun stop()
}

/** Builds the loop for a request; null when the AccessibilityService is not connected. */
fun interface TaskLoopFactory {
    fun create(
        request: TaskRequest,
        events: (LoopEvent) -> Unit,
    ): TaskLoop?
}

/**
 * Owns the one running task: starts the foreground service and the step
 * loop, forwards every step to [listener] (the Flutter UI, while attached)
 * and the notification, and ends it on a stop from the app, the overlay or
 * the notification.
 */
class AgentTaskController(
    private val accessibilityEnabled: () -> Boolean,
    /** Starts the foreground service with the step text; false when Android refuses. */
    private val startService: (String?) -> Boolean,
    private val stopService: () -> Unit,
    private val updateStep: (String) -> Unit,
    private val loops: TaskLoopFactory,
) {
    @Volatile
    var listener: ((StepEvent) -> Unit)? = null

    /** How the last task ended, in memory only: the debug receiver reports it to the eval. */
    @Volatile
    var lastFinished: StepEvent? = null
        private set

    private var loop: TaskLoop? = null
    private var stopHandle: AutoCloseable? = null

    val isRunning: Boolean
        @Synchronized get() = loop != null

    fun start(request: TaskRequest): StartTaskResult {
        val command = request.command.trim()
        val created: TaskLoop
        synchronized(this) {
            val refusal =
                when {
                    command.isEmpty() -> "empty_command"
                    loop != null -> "already_running"
                    !accessibilityEnabled() -> "accessibility_off"
                    !isServerUrl(request.apiBaseUrl) -> "bad_server_url"
                    else -> null
                }
            if (refusal != null) return StartTaskResult(started = false, reason = refusal)
            val built = loops.create(request.copy(command = command), ::onLoopEvent) ?: return StartTaskResult(false, "accessibility_off")
            if (!startService(command)) return StartTaskResult(started = false, reason = "background_start_refused")
            loop = built
            created = built
            stopHandle = StopRequests.register(::stop)
        }
        emit(StepEvent(StepEventKind.STARTED, command))
        created.start()
        return StartTaskResult(started = true)
    }

    /** The user stopped the task; a no-op when none runs. The loop reports the end. */
    fun stop() {
        val running = synchronized(this) { loop } ?: return
        running.stop()
    }

    private fun onLoopEvent(event: LoopEvent) {
        when (event) {
            LoopEvent.Started -> Unit
            is LoopEvent.Step -> {
                updateStep(event.say)
                emit(StepEvent(StepEventKind.STEP, event.say))
            }
            is LoopEvent.Finished -> {
                synchronized(this) {
                    if (loop == null) return
                    loop = null
                    stopHandle?.close()
                    stopHandle = null
                    stopService()
                }
                val finished = StepEvent(StepEventKind.FINISHED, event.reply, event.status, event.reason)
                lastFinished = finished
                emit(finished)
            }
        }
    }

    private fun emit(event: StepEvent) {
        listener?.invoke(event)
    }

    companion object {
        @Volatile
        private var instance: AgentTaskController? = null

        internal fun isServerUrl(url: String): Boolean = url.startsWith("http://") || url.startsWith("https://")

        /** One per process: a task outlives the activity that started it. */
        fun get(context: Context): AgentTaskController =
            instance ?: synchronized(this) {
                instance ?: run {
                    val app = context.applicationContext
                    AgentTaskController(
                        accessibilityEnabled = AccessibilityStatus(app)::isServiceEnabled,
                        startService = { step -> AgentForegroundService.start(app, step) },
                        stopService = { AgentForegroundService.stop(app) },
                        updateStep = { say -> AgentForegroundService.updateStep(app, say) },
                        loops = ::serviceLoop,
                    ).also { instance = it }
                }
            }

        /** The real loop: OkHttp to the API, the AccessibilityService's eyes and hands, the overlay. */
        private fun serviceLoop(
            request: TaskRequest,
            events: (LoopEvent) -> Unit,
        ): TaskLoop? {
            val service = AlesleAccessibilityService.instance ?: return null
            val worker = HandlerLoopWorker()
            val loop =
                AgentLoop(
                    request =
                        LoopRequest(
                            command = request.command,
                            locale = request.locale,
                            policy = if (request.confirmEverySensitiveAction) ConfirmPolicy.CONFIRM else ConfirmPolicy.COUNTDOWN,
                        ),
                    sockets = OkHttpLoopSocketFactory(OkHttpLoopSocketFactory.socketUrl(request.apiBaseUrl), request.accessToken),
                    device = RuntimeLoopDevice({ AlesleAccessibilityService.instance }, { service.lastEventAt }, SystemClock::uptimeMillis),
                    ui = AgentOverlay(service, onStop = StopRequests::request, locale = request.locale),
                    worker = worker,
                    events = { event ->
                        events(event)
                        if (event is LoopEvent.Finished) worker.quit()
                    },
                )
            return object : TaskLoop {
                override fun start() = loop.start()

                override fun stop() = loop.stop()
            }
        }
    }
}
