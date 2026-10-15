package com.alesle.ai.agent.action

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.os.Handler
import android.os.Looper
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class ServiceDeviceControlTest {
    private val service = mockk<AccessibilityService>(relaxed = true)
    private val handler = Handler(Looper.getMainLooper())
    private val control = ServiceDeviceControl(service, handler, capturer = { null })
    private val tap = Gesture(listOf(PixelPoint(10f, 20f)), 50)

    @Test
    fun `maps global actions to the system constants`() {
        every { service.performGlobalAction(any()) } returns true
        assertTrue(control.performGlobal(GlobalAction.BACK))
        assertTrue(control.performGlobal(GlobalAction.HOME))
        assertTrue(control.performGlobal(GlobalAction.RECENTS))
        verify {
            service.performGlobalAction(AccessibilityService.GLOBAL_ACTION_BACK)
            service.performGlobalAction(AccessibilityService.GLOBAL_ACTION_HOME)
            service.performGlobalAction(AccessibilityService.GLOBAL_ACTION_RECENTS)
        }
    }

    @Test
    fun `a completed gesture succeeds, on the worker handler`() {
        val callback = slot<AccessibilityService.GestureResultCallback>()
        every { service.dispatchGesture(any(), capture(callback), handler) } answers {
            callback.captured.onCompleted(firstArg())
            true
        }
        assertTrue(control.performGesture(tap))
    }

    @Test
    fun `a cancelled or refused gesture fails`() {
        val callback = slot<AccessibilityService.GestureResultCallback>()
        every { service.dispatchGesture(any(), capture(callback), any()) } answers {
            callback.captured.onCancelled(firstArg())
            true
        }
        assertFalse(control.performGesture(tap))

        every { service.dispatchGesture(any(), any(), any()) } returns false
        assertFalse(control.performGesture(tap))
    }

    @Test
    fun `an empty gesture is never dispatched`() {
        assertFalse(control.performGesture(Gesture(emptyList(), 50)))
        verify(exactly = 0) { service.dispatchGesture(any(), any(), any()) }
    }

    @Test
    fun `builds one stroke with the gesture duration`() {
        val description: GestureDescription =
            ServiceDeviceControl.toDescription(Gesture(listOf(PixelPoint(-5f, 10f), PixelPoint(100f, 10f)), 300))!!
        assertEquals(1, description.strokeCount)
        assertEquals(300, description.getStroke(0).duration)
        assertNull(ServiceDeviceControl.toDescription(Gesture(emptyList(), 300)))
    }

    @Test
    fun `captures fresh on every call`() {
        var calls = 0
        val counting =
            ServiceDeviceControl(service, handler) {
                calls++
                null
            }
        assertNull(counting.capture())
        assertNull(counting.capture())
        assertEquals(2, calls)
    }
}
