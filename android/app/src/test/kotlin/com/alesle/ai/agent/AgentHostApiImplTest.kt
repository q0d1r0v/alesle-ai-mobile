package com.alesle.ai.agent

import android.app.Application
import android.content.Intent
import android.provider.Settings
import androidx.test.core.app.ApplicationProvider
import io.mockk.every
import io.mockk.mockk
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

@RunWith(RobolectricTestRunner::class)
class AgentHostApiImplTest {
    private val context = ApplicationProvider.getApplicationContext<Application>()

    private fun api(enabled: Boolean): AgentHostApiImpl {
        val status = mockk<AccessibilityStatus> { every { isServiceEnabled() } returns enabled }
        return AgentHostApiImpl(context, status)
    }

    @Test
    fun `reports accessibility as off`() {
        assertEquals(false, api(enabled = false).getStatus().accessibilityEnabled)
    }

    @Test
    fun `reports accessibility as on`() {
        assertEquals(true, api(enabled = true).getStatus().accessibilityEnabled)
    }

    @Test
    fun `opens the system accessibility settings in a new task`() {
        api(enabled = false).openAccessibilitySettings()

        val started: Intent? = shadowOf(context).nextStartedActivity
        assertNotNull(started)
        assertEquals(Settings.ACTION_ACCESSIBILITY_SETTINGS, started!!.action)
        assertTrue(started.flags and Intent.FLAG_ACTIVITY_NEW_TASK != 0)
    }
}
