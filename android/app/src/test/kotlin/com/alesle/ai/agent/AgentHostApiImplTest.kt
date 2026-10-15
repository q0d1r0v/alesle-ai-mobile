package com.alesle.ai.agent

import android.app.Application
import android.content.Intent
import android.provider.Settings
import androidx.test.core.app.ApplicationProvider
import com.alesle.ai.agent.generated.ExecutionPolicyMessage
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

    private fun api(
        enabled: Boolean,
        distribution: String,
    ): AgentHostApiImpl {
        val status = mockk<AccessibilityStatus> { every { isServiceEnabled() } returns enabled }
        return AgentHostApiImpl(context, status, distribution)
    }

    @Test
    fun `reports status for the play build`() {
        val status = api(enabled = false, distribution = "play").getStatus()
        assertEquals(false, status.accessibilityEnabled)
        assertEquals(ExecutionPolicyMessage.CONFIRM_SENSITIVE_ACTIONS, status.policy)
        assertEquals("play", status.distribution)
    }

    @Test
    fun `reports status for the direct build`() {
        val status = api(enabled = true, distribution = "direct").getStatus()
        assertEquals(true, status.accessibilityEnabled)
        assertEquals(ExecutionPolicyMessage.AUTONOMOUS, status.policy)
    }

    @Test
    fun `opens the system accessibility settings in a new task`() {
        api(enabled = false, distribution = "play").openAccessibilitySettings()

        val started: Intent? = shadowOf(context).nextStartedActivity
        assertNotNull(started)
        assertEquals(Settings.ACTION_ACCESSIBILITY_SETTINGS, started!!.action)
        assertTrue(started.flags and Intent.FLAG_ACTIVITY_NEW_TASK != 0)
    }
}
