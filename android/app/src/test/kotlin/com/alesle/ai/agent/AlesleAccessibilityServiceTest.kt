package com.alesle.ai.agent

import android.view.accessibility.AccessibilityEvent
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AlesleAccessibilityServiceTest {
    @Test
    fun `starts and handles events without crashing`() {
        val service = Robolectric.setupService(AlesleAccessibilityService::class.java)
        service.onAccessibilityEvent(null)
        service.onAccessibilityEvent(AccessibilityEvent(AccessibilityEvent.TYPE_VIEW_CLICKED))
        service.onAccessibilityEvent(
            AccessibilityEvent(AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED).apply {
                packageName = "org.telegram.messenger"
                className = "org.telegram.ui.LaunchActivity"
            },
        )
        service.onAccessibilityEvent(AccessibilityEvent(AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED))
        service.onInterrupt()
    }

    @Test
    fun `has no capture while no window is readable`() {
        val service = Robolectric.setupService(AlesleAccessibilityService::class.java)
        assertNull(service.capture())
    }

    @Test
    fun `is not exposed before the system connects it`() {
        val controller = Robolectric.buildService(AlesleAccessibilityService::class.java).create()
        assertNull(AlesleAccessibilityService.instance)
        controller.destroy()
        assertNull(AlesleAccessibilityService.instance)
    }

    @Test
    fun `is not exposed once the system unbinds it`() {
        val controller = Robolectric.buildService(AlesleAccessibilityService::class.java).create()
        val service = controller.get()
        // Protected: the system calls it once the service is bound.
        AlesleAccessibilityService::class.java
            .getDeclaredMethod("onServiceConnected")
            .apply { isAccessible = true }
            .invoke(service)
        assertSame(service, AlesleAccessibilityService.instance)
        service.onUnbind(null)
        assertNull(AlesleAccessibilityService.instance)
        controller.destroy()
    }
}
