package com.alesle.ai.agent.task

import android.app.Application
import androidx.test.core.app.ApplicationProvider
import com.alesle.ai.agent.generated.StartTaskResult
import com.alesle.ai.agent.generated.StepEvent
import com.alesle.ai.agent.generated.StepEventKind
import com.alesle.ai.agent.generated.TaskRequest
import com.alesle.ai.agent.loop.LoopEvent
import com.alesle.ai.agent.service.StopRequests
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AgentTaskControllerTest {
    private val app = ApplicationProvider.getApplicationContext<Application>()
    private var accessibility = true
    private var serviceAllowed = true
    private var serviceConnected = true
    private val started = mutableListOf<String?>()
    private val steps = mutableListOf<String>()
    private var stopped = 0
    private val events = mutableListOf<StepEvent>()
    private val loops = mutableListOf<FakeLoop>()

    private inner class FakeLoop(
        val request: TaskRequest,
        val events: (LoopEvent) -> Unit,
    ) : TaskLoop {
        var starts = 0
        var stops = 0

        override fun start() {
            starts++
        }

        override fun stop() {
            stops++
            events(LoopEvent.Finished("stopped", "user_stopped", null))
        }
    }

    private val controller =
        AgentTaskController(
            accessibilityEnabled = { accessibility },
            startService = { step -> serviceAllowed.also { if (it) started += step } },
            stopService = { stopped++ },
            updateStep = { steps += it },
            loops = { request, events -> if (serviceConnected) FakeLoop(request, events).also { loops += it } else null },
        ).apply { listener = { events += it } }

    private fun request(command: String = "  Onamga qo'ng'iroq qil ") =
        TaskRequest(command, "http://127.0.0.1:3000", "dev-token", "uz", confirmEverySensitiveAction = true)

    @After
    fun tearDown() = controller.stop()

    @Test
    fun `starts the service and the loop with the trimmed command`() {
        assertEquals(StartTaskResult(started = true), controller.start(request()))
        assertEquals(listOf<String?>("Onamga qo'ng'iroq qil"), started)
        assertEquals("Onamga qo'ng'iroq qil", loops.single().request.command)
        assertEquals(1, loops.single().starts)
        assertEquals(listOf(StepEvent(StepEventKind.STARTED, "Onamga qo'ng'iroq qil")), events)
        assertTrue(controller.isRunning)
    }

    @Test
    fun `refuses to start with a reason`() {
        assertEquals("empty_command", controller.start(request("   ")).reason)
        assertEquals("bad_server_url", controller.start(request().copy(apiBaseUrl = "ftp://x")).reason)

        accessibility = false
        assertEquals("accessibility_off", controller.start(request()).reason)
        accessibility = true

        serviceConnected = false
        assertEquals("accessibility_off", controller.start(request()).reason)
        serviceConnected = true

        serviceAllowed = false
        assertEquals("background_start_refused", controller.start(request()).reason)
        serviceAllowed = true

        controller.start(request("birinchi"))
        assertEquals(StartTaskResult(started = false, reason = "already_running"), controller.start(request("ikkinchi")))
        assertEquals(listOf<String?>("birinchi"), started)
    }

    @Test
    fun `forwards steps to the app and the notification`() {
        controller.start(request())
        loops.single().events(LoopEvent.Started)
        loops.single().events(LoopEvent.Step("Telegram ochilmoqda"))
        assertEquals(listOf("Telegram ochilmoqda"), steps)
        assertEquals(StepEvent(StepEventKind.STEP, "Telegram ochilmoqda"), events.last())
        assertEquals(2, events.size)
    }

    @Test
    fun `ends with the loop's result and stops the service once`() {
        controller.start(request())
        loops.single().events(LoopEvent.Finished("done", null, "Bajarildi"))
        loops.single().events(LoopEvent.Finished("done", null, "again"))
        assertEquals(1, stopped)
        assertFalse(controller.isRunning)
        assertEquals(StepEvent(StepEventKind.FINISHED, "Bajarildi", "done", null), events.last())
        assertEquals(1, events.count { it.kind == StepEventKind.FINISHED })
        assertEquals(events.last(), controller.lastFinished)
    }

    @Test
    fun `stop goes to the loop, from the app or the notification`() {
        controller.start(request())
        StopRequests.request()
        assertEquals(1, loops.single().stops)
        assertEquals(StepEvent(StepEventKind.FINISHED, null, "stopped", "user_stopped"), events.last())

        // Nothing runs any more: further stops do nothing.
        controller.stop()
        StopRequests.request()
        assertEquals(1, loops.single().stops)
    }

    @Test
    fun `works without a listener`() {
        controller.listener = null
        assertTrue(controller.start(request()).started)
        controller.stop()
        assertTrue(events.isEmpty())
    }

    @Test
    fun `one controller per process`() {
        val first = AgentTaskController.get(app)
        assertSame(first, AgentTaskController.get(app))
        // Accessibility is off under Robolectric, so the real wiring refuses.
        assertEquals("accessibility_off", first.start(request()).reason)
    }

    @Test
    fun `accepts only http and https servers`() {
        assertTrue(AgentTaskController.isServerUrl("http://10.0.2.2:3000"))
        assertTrue(AgentTaskController.isServerUrl("https://api.alesle.ai"))
        assertFalse(AgentTaskController.isServerUrl("ws://x"))
    }
}
