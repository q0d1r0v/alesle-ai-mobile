package com.alesle.ai.agent

import android.app.Application
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.provider.Settings
import androidx.test.core.app.ApplicationProvider
import com.alesle.ai.agent.debug.DebugCommands
import com.alesle.ai.agent.generated.FlutterError
import com.alesle.ai.agent.generated.StartTaskResult
import com.alesle.ai.agent.task.AgentTaskController
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

@RunWith(RobolectricTestRunner::class)
class AgentHostApiImplTest {
    private val context = ApplicationProvider.getApplicationContext<Application>()

    private val tasks = mockk<AgentTaskController>(relaxed = true)
    private val debug = mockk<DebugCommands>()

    private fun api(
        enabled: Boolean,
        appContext: Context = context,
    ): AgentHostApiImpl {
        val status = mockk<AccessibilityStatus> { every { isServiceEnabled() } returns enabled }
        return AgentHostApiImpl(appContext, status, tasks, debug)
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

    @Test
    fun `starts and stops tasks through the controller`() {
        every { tasks.start("salom") } returns StartTaskResult(started = true)
        assertEquals(StartTaskResult(started = true), api(enabled = true).startTask("salom"))
        api(enabled = true).stopTask()
        verify { tasks.stop() }
    }

    @Test
    fun `debug commands work in debug builds`() {
        // Robolectric runs the debug variant: the app is debuggable.
        every { debug.snapshot() } returns JSONObject().put("captureMs", 7)
        every { debug.execute("{}") } returns JSONObject().put("status", "ok")
        assertEquals("""{"captureMs":7}""", api(enabled = true).debugSnapshot())
        assertEquals("""{"status":"ok"}""", api(enabled = true).debugExecute("{}"))
    }

    @Test
    fun `debug commands are refused in release builds`() {
        val release =
            mockk<Context> {
                every { applicationInfo } returns ApplicationInfo().apply { flags = 0 }
            }
        val api = api(enabled = true, appContext = release)
        assertEquals("debug_only", assertThrows(FlutterError::class.java) { api.debugSnapshot() }.code)
        assertEquals("debug_only", assertThrows(FlutterError::class.java) { api.debugExecute("{}") }.code)
    }
}
