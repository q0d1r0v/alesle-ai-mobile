package com.alesle.ai.agent.loop

import com.alesle.ai.agent.action.ActionResult
import com.alesle.ai.agent.action.AgentAction
import com.alesle.ai.agent.action.Choice
import com.alesle.ai.agent.protocol.ActionDecodeException
import com.alesle.ai.agent.protocol.ActionJson
import com.alesle.ai.agent.protocol.DecodedAction
import com.alesle.ai.agent.snapshot.CapturedScreen
import com.alesle.ai.agent.vision.Screenshot
import java.util.concurrent.atomic.AtomicBoolean

/** One connection to `/v1/agent/ws`; [send] and [close] may be called from any thread. */
interface LoopSocket {
    fun send(text: String): Boolean

    fun close()
}

/** Socket callbacks; they may arrive on any thread. */
interface LoopSocketListener {
    fun onOpen()

    fun onMessage(text: String)

    /** Closed or failed: either way the connection is gone. */
    fun onGone()
}

fun interface LoopSocketFactory {
    fun connect(listener: LoopSocketListener): LoopSocket
}

/** The agent's eyes and hands for the loop. Blocking; called on the loop's worker only. */
interface LoopDevice {
    fun capture(): CapturedScreen?

    /** [screen] is the last capture: node ids in the action refer to it. */
    fun execute(
        action: DecodedAction,
        screen: CapturedScreen?,
    ): ActionResult

    /** Waits until the screen stops changing after an action. */
    fun settle()

    /** The screen as a picture (SOW 03 §3). */
    fun screenshot(): Screenshot
}

/** What the user sees while a task runs: the overlay. Answers may come back on any thread. */
interface LoopUi {
    fun showStep(say: String)

    /** [countdown]: a cancellable 3 s countdown instead of a question. */
    fun confirm(
        confirmation: Confirmation,
        countdown: Boolean,
        answer: (approved: Boolean) -> Unit,
    )

    fun ask(
        question: String,
        choices: List<Choice>,
        answer: (ref: String?) -> Unit,
    )

    fun hide()

    /**
     * Runs [capture] with the overlay out of the picture: the glow and the
     * pill would otherwise cover the app's own header in the screenshot.
     */
    fun <T> concealed(capture: () -> T): T
}

/** Runs work one item at a time, in order, off the main thread. */
interface LoopWorker {
    fun post(task: () -> Unit)

    fun postDelayed(
        delayMs: Long,
        task: () -> Unit,
    )
}

sealed interface LoopEvent {
    data object Started : LoopEvent

    data class Step(
        val say: String,
    ) : LoopEvent

    /** [status]: done, failed, cannot, stopped, interrupted (protocol); [reply] is user-facing. */
    data class Finished(
        val status: String,
        val reason: String?,
        val reply: String?,
    ) : LoopEvent
}

data class LoopRequest(
    val command: String,
    val locale: String,
    val policy: ConfirmPolicy,
)

/**
 * The phone's half of the step loop (alesle-ai-api docs/agent-protocol.md):
 * observe and act as the server says, ask the user what only they can answer,
 * and survive a dropped connection by resuming the task.
 *
 * Two device-side rules hold whatever the server sends: a step marked
 * sensitive never runs without the user's yes (or an uncancelled countdown
 * when they chose that), and a step id runs at most once.
 */
class AgentLoop(
    private val request: LoopRequest,
    private val sockets: LoopSocketFactory,
    private val device: LoopDevice,
    private val ui: LoopUi,
    private val worker: LoopWorker,
    private val events: (LoopEvent) -> Unit,
    private val reconnectDelaysMs: List<Long> = RECONNECT_DELAYS_MS,
) {
    /** Set from any thread by [stop]; the worker checks it around every action. */
    private val ended = AtomicBoolean(false)

    @Volatile
    private var socket: LoopSocket? = null
    private var taskId: String? = null
    private var lastScreen: CapturedScreen? = null
    private var executed: Pair<String, ActionResult>? = null

    /** The step waiting for the user; a re-sent act for it must not start a second wait. */
    private var waitingStep: String? = null
    private var reconnects = 0

    fun start() {
        worker.post(::connect)
    }

    /**
     * STOP (AC-AG-7): ends the task on the phone at once, without waiting for
     * a running action or for the server's answer.
     */
    fun stop() {
        end(LoopEvent.Finished("stopped", "user_stopped", null), notifyServer = true)
    }

    private fun connect() {
        if (ended.get()) return
        val listener =
            object : LoopSocketListener {
                override fun onOpen() = worker.post(::opened)

                override fun onMessage(text: String) = worker.post { received(text) }

                override fun onGone() = worker.post(::gone)
            }
        socket = sockets.connect(listener)
    }

    private fun opened() {
        if (ended.get()) return
        reconnects = 0
        val id = taskId
        send(if (id == null) LoopFrames.start(request.command, request.locale, request.policy) else LoopFrames.resume(id))
    }

    private fun gone() {
        if (ended.get()) return
        if (taskId == null) {
            end(LoopEvent.Finished("failed", "server_unreachable", null), notifyServer = false)
            return
        }
        val delay = reconnectDelaysMs.getOrNull(reconnects++)
        if (delay == null) {
            end(LoopEvent.Finished("interrupted", "connection_lost", null), notifyServer = false)
            return
        }
        worker.postDelayed(delay, ::connect)
    }

    private fun received(text: String) {
        if (ended.get()) return
        when (val frame = LoopFrames.decode(text) ?: return) {
            is ServerFrame.Accepted -> {
                val first = taskId == null
                taskId = frame.taskId
                if (first) events(LoopEvent.Started)
            }
            is ServerFrame.Observe -> if (frame.screenshot) look() else observe(null, null)
            is ServerFrame.Act -> act(frame)
            is ServerFrame.Ask ->
                ui.ask(frame.question, frame.choices) { ref ->
                    worker.post { if (!ended.get()) send(LoopFrames.reply(frame.askId, ref)) }
                }
            is ServerFrame.Finish ->
                end(LoopEvent.Finished(frame.status, frame.reason, frame.reply), notifyServer = false)
            is ServerFrame.Error ->
                when (frame.code) {
                    "already_running" -> end(LoopEvent.Finished("failed", "already_running", null), notifyServer = false)
                    "unknown_task" -> end(LoopEvent.Finished("interrupted", "connection_lost", null), notifyServer = false)
                    // bad_frame / no_task: our bug or a race; the server keeps the task going.
                    else -> Unit
                }
        }
    }

    private fun act(frame: ServerFrame.Act) {
        val done = executed
        if (done != null && done.first == frame.stepId) {
            // Re-sent after a reconnect: report, never run twice.
            observe(frame.stepId, done.second)
            return
        }
        if (frame.stepId == waitingStep) return
        ui.showStep(frame.say)
        events(LoopEvent.Step(frame.say))
        val decoded =
            try {
                ActionJson.decode(frame.action)
            } catch (e: ActionDecodeException) {
                finishStep(frame.stepId, ActionResult.error(e.reason))
                return
            }
        if (decoded is DecodedAction.WaitForUser) {
            waitForUser(frame.stepId, decoded.timeoutMs)
            return
        }
        val confirm = frame.confirm
        if (confirm == null) {
            run(frame.stepId, decoded)
            return
        }
        val ask = request.policy == ConfirmPolicy.CONFIRM || confirm.always
        ui.confirm(confirm, countdown = !ask) { approved ->
            worker.post {
                if (ended.get()) return@post
                if (approved) run(frame.stepId, decoded) else finishStep(frame.stepId, ActionResult.DECLINED)
            }
        }
    }

    private fun run(
        stepId: String,
        action: DecodedAction,
    ) {
        if (ended.get()) return
        // A gesture lands on whatever window is on top: with the overlay there,
        // a tap on an app's top bar would press our own STOP (eval, 2026-10-16).
        val result =
            if (touchesScreen(action)) {
                ui.concealed { device.execute(action, lastScreen) }
            } else {
                device.execute(action, lastScreen)
            }
        if (ended.get()) return
        device.settle()
        finishStep(stepId, result)
    }

    /**
     * A permission dialog or a lock screen is the user's to answer: no sheet
     * over it (it would hide the dialog's own buttons, eval 2026-10-16), only
     * the pill saying what to do. Done when the screen changes.
     */
    private fun waitForUser(
        stepId: String,
        timeoutMs: Long,
    ) {
        waitingStep = stepId
        val before = (lastScreen ?: device.capture())?.snapshot?.screenHash
        pollUser(stepId, before, polls = (timeoutMs / USER_POLL_MS).toInt().coerceAtLeast(1))
    }

    private fun pollUser(
        stepId: String,
        before: String?,
        polls: Int,
    ) {
        worker.postDelayed(USER_POLL_MS) {
            if (ended.get()) return@postDelayed
            val now = device.capture()?.snapshot?.screenHash
            when {
                now != null && now != before -> {
                    waitingStep = null
                    device.settle()
                    finishStep(stepId, ActionResult.OK)
                }
                polls <= 1 -> {
                    waitingStep = null
                    finishStep(stepId, ActionResult.error(USER_TIMEOUT))
                }
                else -> pollUser(stepId, before, polls - 1)
            }
        }
    }

    /** Actions that may fall back to a gesture; waits, global keys and intents never touch the screen. */
    private fun touchesScreen(action: DecodedAction): Boolean =
        action is DecodedAction.Screen &&
            action.action !is AgentAction.Wait &&
            action.action !is AgentAction.Global

    private fun finishStep(
        stepId: String,
        result: ActionResult,
    ) {
        executed = stepId to result
        observe(stepId, result)
    }

    private fun observe(
        stepId: String?,
        result: ActionResult?,
    ) {
        val screen = device.capture()
        lastScreen = screen
        send(LoopFrames.observation(stepId, result, screen?.snapshot?.toJson()))
    }

    private fun look() {
        val screen = device.capture()
        lastScreen = screen
        val picture = ui.concealed(device::screenshot)
        send(LoopFrames.lookObservation(screen?.snapshot?.toJson(), picture))
    }

    private fun send(text: String) {
        socket?.send(text)
    }

    /** Ends once, from any thread. */
    private fun end(
        event: LoopEvent.Finished,
        notifyServer: Boolean,
    ) {
        if (!ended.compareAndSet(false, true)) return
        val current = socket
        if (notifyServer) current?.send(LoopFrames.stop())
        ui.hide()
        events(event)
        current?.close()
    }

    companion object {
        /** About 28 s in all: inside the server's 30 s grace (EC-1). */
        val RECONNECT_DELAYS_MS = listOf(1_000L, 2_000L, 4_000L, 8_000L, 8_000L, 5_000L)

        const val USER_POLL_MS = 700L
        const val USER_TIMEOUT = "user_timeout"
    }
}
