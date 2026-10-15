package com.alesle.ai.agent

import android.view.accessibility.AccessibilityEvent
import org.junit.Assert.assertNull
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
    fun `has no snapshot while no window is readable`() {
        val service = Robolectric.setupService(AlesleAccessibilityService::class.java)
        assertNull(service.captureSnapshot())
    }

    @Test
    fun `is not exposed before the system connects it`() {
        val controller = Robolectric.buildService(AlesleAccessibilityService::class.java).create()
        assertNull(AlesleAccessibilityService.instance)
        controller.destroy()
        assertNull(AlesleAccessibilityService.instance)
    }
}
