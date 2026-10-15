package com.alesle.ai.agent

import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AlesleAccessibilityServiceTest {
    @Test
    fun `phase-1 service starts and ignores events without crashing`() {
        val service = Robolectric.setupService(AlesleAccessibilityService::class.java)
        service.onAccessibilityEvent(null)
        service.onInterrupt()
    }
}
