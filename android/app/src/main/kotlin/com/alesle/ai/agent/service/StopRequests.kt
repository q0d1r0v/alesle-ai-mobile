package com.alesle.ai.agent.service

import java.util.concurrent.CopyOnWriteArraySet

/**
 * The user asked to stop the running task from outside the agent loop: the
 * notification's "To'xtatish" today, the overlay's STOP later (AC-AG-7). The
 * loop registers a listener for as long as a task runs.
 */
object StopRequests {
    private val listeners = CopyOnWriteArraySet<() -> Unit>()

    /** Close the returned handle when the task ends. */
    fun register(listener: () -> Unit): AutoCloseable {
        listeners += listener
        return AutoCloseable { listeners -= listener }
    }

    fun request() {
        listeners.forEach { it() }
    }
}
