package com.alesle.ai.agent.debug

import com.alesle.ai.agent.AgentRuntime
import com.alesle.ai.agent.action.DeviceControl
import com.alesle.ai.agent.action.Gesture
import com.alesle.ai.agent.action.GlobalAction
import com.alesle.ai.agent.intent.IntentAction
import com.alesle.ai.agent.intent.IntentLauncher
import com.alesle.ai.agent.snapshot.Bounds
import com.alesle.ai.agent.snapshot.CapturedScreen
import com.alesle.ai.agent.snapshot.Orientation
import com.alesle.ai.agent.snapshot.SnapshotBuilder
import com.alesle.ai.agent.snapshot.SnapshotContext
import com.alesle.ai.agent.snapshot.UiNode
import com.alesle.ai.agent.vision.Screenshot
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertSame
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import com.alesle.ai.agent.action.ActionResult as Result

@RunWith(RobolectricTestRunner::class)
class DebugCommandsTest {
    private val button = Button()
    private val screen = captured(button)
    private val device = FakeDevice(screen)
    private val launcher = mockk<IntentLauncher>()
    private val runtime = FakeRuntime(screen, device, launcher)

    private var clock = 0L
    private val commands = DebugCommands({ runtime }, nanoTime = { clock.also { clock += 42_000_000 } })

    private fun JSONObject.reason() = optString("reason")

    @Test
    fun `snapshot returns the screen and how long the capture took`() {
        val answer = commands.snapshot()
        assertEquals(42L, answer.getLong("captureMs"))
        assertEquals("com.example", answer.getJSONObject("snapshot").getString("package"))
        assertEquals(
            "Yuborish",
            answer
                .getJSONObject("snapshot")
                .getJSONArray("nodes")
                .getJSONObject(0)
                .getString("text"),
        )
    }

    @Test
    fun `actions tap nodes of the last snapshot`() {
        commands.snapshot()
        assertEquals("""{"status":"ok"}""", commands.execute("""{"type":"tap","nodeId":0}""").toString())
        assertEquals(1, button.clicks)
        assertEquals(0, device.captures)
    }

    @Test
    fun `without a snapshot an action captures the screen first`() {
        assertEquals("ok", commands.execute("""{"type":"tap","nodeId":0}""").getString("status"))
        assertEquals(1, device.captures)
    }

    @Test
    fun `intents go to the intent launcher`() {
        every { launcher.execute(any()) } returns Result.notFound("app_not_installed")
        val answer = commands.execute("""{"type":"launch_app","name":"Uzum"}""")
        assertEquals("not_found", answer.getString("status"))
        verify { launcher.execute(IntentAction.LaunchApp(appName = "Uzum")) }
    }

    @Test
    fun `reports malformed actions and a missing runtime`() {
        assertEquals("invalid_json", commands.execute("nope").reason())

        val off = DebugCommands({ null })
        assertEquals("accessibility_off", off.snapshot().reason())
        assertEquals("accessibility_off", off.execute("""{"type":"back"}""").reason())

        runtime.screen = null
        assertEquals("no_window", commands.snapshot().reason())
        device.screen = null
        assertEquals("no_window", commands.execute("""{"type":"back"}""").reason())
    }

    @Test
    fun `reports a runtime without hands`() {
        val bare = DebugCommands({ FakeRuntime(screen, null, null) })
        assertEquals("accessibility_off", bare.execute("""{"type":"back"}""").reason())
        assertEquals("accessibility_off", bare.execute("""{"type":"intent","kind":"web_search","query":"x"}""").reason())
    }

    @Test
    fun `one instance is shared per process`() {
        assertSame(DebugCommands.shared, DebugCommands.shared)
        assertEquals("accessibility_off", DebugCommands.shared.snapshot().reason())
    }
}

private fun captured(vararg nodes: UiNode): CapturedScreen {
    val root = Button(text = null, clickable = false, kids = nodes.toList())
    val context = SnapshotContext("com.example", null, "uz-UZ", Orientation.PORTRAIT, false, Bounds(0, 0, 1080, 2400))
    return SnapshotBuilder().build(root, context)
}

private class Button(
    override val text: String? = "Yuborish",
    clickable: Boolean = true,
    kids: List<UiNode> = emptyList(),
) : UiNode {
    var clicks = 0
    override val className = "android.widget.Button"
    override val contentDescription: String? = null
    override val hintText: String? = null
    override val isShowingHintText = false
    override val viewId: String? = null
    override val bounds = Bounds(0, 0, 1080, 200)
    override val isVisibleToUser = true
    override val isClickable = clickable
    override val isLongClickable = false
    override val isEditable = false
    override val isEnabled = true
    override val isFocused = false
    override val isScrollable = false
    override val isCheckable = false
    override val isChecked = false
    override val isPassword = false
    override val children = kids

    override fun click(): Boolean {
        clicks++
        return true
    }
}

private class FakeDevice(
    var screen: CapturedScreen?,
) : DeviceControl {
    var captures = 0

    override fun capture(): CapturedScreen? {
        captures++
        return screen
    }

    override fun performGlobal(action: GlobalAction) = true

    override fun performGesture(gesture: Gesture) = true
}

private class FakeRuntime(
    var screen: CapturedScreen?,
    override val deviceControl: DeviceControl?,
    override val intentLauncher: IntentLauncher?,
) : AgentRuntime {
    override fun capture() = screen

    override fun screenshot(): Screenshot = Screenshot.Unavailable
}
