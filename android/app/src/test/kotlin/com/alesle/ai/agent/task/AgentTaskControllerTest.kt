package com.alesle.ai.agent.task

import android.app.Application
import androidx.test.core.app.ApplicationProvider
import com.alesle.ai.agent.generated.StartTaskResult
import com.alesle.ai.agent.generated.StepEvent
import com.alesle.ai.agent.generated.StepEventKind
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
    private val started = mutableListOf<String?>()
    private var stopped = 0
    private val events = mutableListOf<StepEvent>()

    private val controller =
        AgentTaskController(
            accessibilityEnabled = { accessibility },
            startService = { step -> serviceAllowed.also { if (it) started += step } },
            stopService = { stopped++ },
        ).apply { listener = { events += it } }

    @After
    fun tearDown() = controller.stop()

    @Test
    fun `starts the foreground service with the command and reports it`() {
        assertEquals(StartTaskResult(started = true), controller.start("  Onamga qo'ng'iroq qil "))
        assertEquals(listOf<String?>("Onamga qo'ng'iroq qil"), started)
        assertEquals(listOf(StepEvent(StepEventKind.STARTED, "Onamga qo'ng'iroq qil")), events)
        assertTrue(controller.isRunning)
    }

    @Test
    fun `refuses to start with a reason`() {
        assertEquals("empty_command", controller.start("   ").reason)

        accessibility = false
        assertEquals("accessibility_off", controller.start("salom").reason)

        accessibility = true
        serviceAllowed = false
        assertEquals("background_start_refused", controller.start("salom").reason)

        serviceAllowed = true
        controller.start("birinchi")
        assertEquals(StartTaskResult(started = false, reason = "already_running"), controller.start("ikkinchi"))
        assertEquals(listOf<String?>("birinchi"), started)
    }

    @Test
    fun `stop ends the service once and reports it`() {
        controller.start("salom")
        controller.stop()
        controller.stop()
        assertEquals(1, stopped)
        assertFalse(controller.isRunning)
        assertEquals(StepEvent(StepEventKind.STOPPED), events.last())
    }

    @Test
    fun `the notification's stop reaches the running task only`() {
        StopRequests.request()
        assertEquals(0, stopped)

        controller.start("salom")
        StopRequests.request()
        assertEquals(1, stopped)
        assertFalse(controller.isRunning)

        // After the task ended its stop listener is gone.
        StopRequests.request()
        assertEquals(1, stopped)
    }

    @Test
    fun `works without a listener`() {
        controller.listener = null
        assertTrue(controller.start("salom").started)
        controller.stop()
        assertTrue(events.isEmpty())
    }

    @Test
    fun `one controller per process`() {
        val first = AgentTaskController.get(app)
        assertSame(first, AgentTaskController.get(app))
        // Accessibility is off under Robolectric, so the real wiring refuses.
        assertEquals("accessibility_off", first.start("salom").reason)
    }
}
