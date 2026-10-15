package com.alesle.ai.agent.loop

import android.os.Handler
import android.os.HandlerThread

/** A [LoopWorker] on its own thread; [quit] once the task has ended. */
class HandlerLoopWorker(
    name: String = "alesle-agent",
) : LoopWorker {
    private val thread = HandlerThread(name).apply { start() }
    private val handler = Handler(thread.looper)

    override fun post(task: () -> Unit) {
        handler.post(task)
    }

    override fun postDelayed(
        delayMs: Long,
        task: () -> Unit,
    ) {
        handler.postDelayed(task, delayMs)
    }

    fun quit() {
        thread.quitSafely()
    }
}
