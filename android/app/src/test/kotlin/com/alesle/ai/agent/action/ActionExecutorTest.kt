package com.alesle.ai.agent.action

import com.alesle.ai.agent.snapshot.Bounds
import com.alesle.ai.agent.snapshot.CapturedScreen
import com.alesle.ai.agent.snapshot.Orientation
import com.alesle.ai.agent.snapshot.ScrollDirection
import com.alesle.ai.agent.snapshot.SnapshotBuilder
import com.alesle.ai.agent.snapshot.SnapshotContext
import com.alesle.ai.agent.snapshot.UiNode
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class ActionExecutorTest {
    private val screenBounds = Bounds(0, 0, 1000, 2000)

    private var clock = 0L
    private val sleeps = mutableListOf<Long>()
    private val device = FakeDevice()
    private val executor =
        ActionExecutor(
            device = device,
            sleep = {
                sleeps += it
                clock += it
            },
            now = { clock },
        )

    private fun capture(
        vararg nodes: ActionNode,
        packageName: String = "org.telegram.messenger",
    ): CapturedScreen =
        SnapshotBuilder(newSnapshotId = { "s" }).build(
            ActionNode(className = "android.widget.FrameLayout", children = nodes.toList()),
            SnapshotContext(packageName, null, "uz", Orientation.PORTRAIT, false, screenBounds),
        )

    private fun run(
        action: AgentAction,
        screen: CapturedScreen,
    ) = executor.execute(action, screen)

    // --- tap / long press ---

    @Test
    fun `taps a clickable node through the accessibility API`() {
        val send = ActionNode(text = "Send", isClickable = true)
        assertEquals(ActionResult.OK, run(AgentAction.Tap(Target.Node(0)), capture(send)))
        assertEquals(1, send.clicks)
        assertTrue(device.gestures.isEmpty())
    }

    @Test
    fun `falls back to a gesture at the centre of a node that cannot be clicked`() {
        val label = ActionNode(text = "Onam", bounds = Bounds(100, 200, 300, 400))
        assertEquals(ActionResult.OK, run(AgentAction.Tap(Target.Node(0)), capture(label)))
        assertEquals(0, label.clicks)
        assertEquals(Gesture(listOf(PixelPoint(200f, 300f)), ActionExecutor.TAP_MS), device.gestures.single())
    }

    @Test
    fun `falls back to a gesture when the click is refused`() {
        val send = ActionNode(text = "Send", isClickable = true, clickResult = false)
        assertEquals(ActionResult.OK, run(AgentAction.Tap(Target.Node(0)), capture(send)))
        assertEquals(1, device.gestures.size)
    }

    @Test
    fun `reports a gesture the system did not complete`() {
        device.gestureResult = false
        val result = run(AgentAction.Tap(Target.Node(0)), capture(ActionNode(text = "x")))
        assertEquals(ActionResult.error("gesture_failed"), result)
    }

    @Test
    fun `reports unknown and vanished nodes as not found`() {
        val gone = ActionNode(text = "gone", isClickable = true, alive = false)
        assertEquals(ActionStatus.NOT_FOUND, run(AgentAction.Tap(Target.Node(5)), capture(gone)).status)
        assertEquals(ActionStatus.NOT_FOUND, run(AgentAction.Tap(Target.Node(0)), capture(gone)).status)
        assertEquals(0, gone.clicks)
    }

    @Test
    fun `does not press a disabled node`() {
        val node = ActionNode(text = "Send", isClickable = true, isEnabled = false)
        assertEquals(ActionResult.blocked("node_disabled"), run(AgentAction.Tap(Target.Node(0)), capture(node)))
        assertEquals(0, node.clicks)
        assertTrue(device.gestures.isEmpty())
    }

    @Test
    fun `taps a normalised point in screen pixels`() {
        assertEquals(ActionResult.OK, run(AgentAction.Tap(Target.Point(0.25, 0.5)), capture()))
        assertEquals(
            PixelPoint(250f, 1000f),
            device.gestures
                .single()
                .points
                .single(),
        )
    }

    @Test
    fun `rejects a point outside the screen`() {
        assertEquals(ActionResult.error("point_out_of_range"), run(AgentAction.Tap(Target.Point(1.2, 0.5)), capture()))
        assertEquals(ActionResult.error("point_out_of_range"), run(AgentAction.Tap(Target.Point(0.5, -0.1)), capture()))
        assertTrue(device.gestures.isEmpty())
    }

    @Test
    fun `never presses inside a system permission dialog`() {
        ActionExecutor.PERMISSION_PACKAGES.forEach { pkg ->
            val allow = ActionNode(text = "Allow", isClickable = true)
            val screen = capture(allow, packageName = pkg)
            assertEquals(pkg, ActionResult.blocked("permission_dialog"), run(AgentAction.Tap(Target.Node(0)), screen))
            assertEquals(pkg, ActionResult.blocked("permission_dialog"), run(AgentAction.Tap(Target.Point(0.5, 0.5)), screen))
            assertEquals(pkg, ActionResult.blocked("permission_dialog"), run(AgentAction.LongPress(Target.Node(0)), screen))
            assertEquals(0, allow.clicks)
        }
        assertTrue(device.gestures.isEmpty())
    }

    @Test
    fun `never presses a permission node shown over another app`() {
        val allow = ActionNode(text = "Allow", isClickable = true, packageName = "com.google.android.permissioncontroller")
        assertEquals(ActionResult.blocked("permission_dialog"), run(AgentAction.Tap(Target.Node(0)), capture(allow)))
        assertEquals(0, allow.clicks)
    }

    @Test
    fun `long-presses through the API, else with a long gesture`() {
        val message = ActionNode(text = "Salom", isLongClickable = true)
        assertEquals(ActionResult.OK, run(AgentAction.LongPress(Target.Node(0)), capture(message)))
        assertEquals(1, message.longClicks)

        val plain = ActionNode(text = "Salom", isClickable = true)
        assertEquals(ActionResult.OK, run(AgentAction.LongPress(Target.Node(0)), capture(plain)))
        assertEquals(0, plain.clicks)
        assertEquals(ActionExecutor.LONG_PRESS_MS, device.gestures.single().durationMs)
    }

    // --- type text ---

    @Test
    fun `types into an editable field and submits when asked`() {
        val field = ActionNode(isEditable = true, isClickable = true)
        assertEquals(ActionResult.OK, run(AgentAction.TypeText(0, "Kech qolaman"), capture(field)))
        assertEquals(listOf("Kech qolaman"), field.typed)
        assertEquals(0, field.imeEnters)

        assertEquals(ActionResult.OK, run(AgentAction.TypeText(0, "Salom", submit = true), capture(field)))
        assertEquals(1, field.imeEnters)
    }

    @Test
    fun `focuses the field before typing, like a tap`() {
        val field = ActionNode(isEditable = true, isClickable = true)
        run(AgentAction.TypeText(0, "salom"), capture(field))
        assertEquals(1, field.clicks)
        assertEquals(listOf("salom"), field.typed)

        // Already focused: no extra tap.
        run(AgentAction.TypeText(0, "yana"), capture(field))
        assertEquals(1, field.clicks)
    }

    @Test
    fun `falls back to input focus when the field takes no click`() {
        val field = ActionNode(isEditable = true, clickResult = false, focusResult = true)
        assertEquals(ActionResult.OK, run(AgentAction.TypeText(0, "salom"), capture(field)))
        assertEquals(1, field.focuses)
        assertTrue(sleeps.isEmpty())
    }

    @Test
    fun `waits briefly for focus and types anyway`() {
        val slow = ActionNode(isEditable = true, focusOnClick = false)
        assertEquals(ActionResult.OK, run(AgentAction.TypeText(0, "salom"), capture(slow)))
        assertEquals(ActionExecutor.FOCUS_WAIT_MS, sleeps.sum())
        assertEquals(listOf("salom"), slow.typed)

        sleeps.clear()
        val stubborn = ActionNode(isEditable = true, clickResult = false)
        assertEquals(ActionResult.OK, run(AgentAction.TypeText(0, "salom"), capture(stubborn)))
        assertTrue(sleeps.isEmpty())
    }

    @Test
    fun `never types into a password field`() {
        val password = ActionNode(isEditable = true, isPassword = true)
        assertEquals(ActionResult.blocked("password_field"), run(AgentAction.TypeText(0, "secret"), capture(password)))
        assertTrue(password.typed.isEmpty())
    }

    @Test
    fun `never types inside a permission dialog`() {
        val field = ActionNode(isEditable = true)
        val result = run(AgentAction.TypeText(0, "x"), capture(field, packageName = "com.android.packageinstaller"))
        assertEquals(ActionResult.blocked("permission_dialog"), result)
        val overlay = ActionNode(isEditable = true, packageName = "com.android.permissioncontroller")
        assertEquals(ActionResult.blocked("permission_dialog"), run(AgentAction.TypeText(0, "x"), capture(overlay)))
        assertTrue(field.typed.isEmpty() && overlay.typed.isEmpty())
    }

    @Test
    fun `explains why text could not be typed`() {
        assertEquals(
            ActionResult.error("not_editable"),
            run(AgentAction.TypeText(0, "x"), capture(ActionNode(text = "label"))),
        )
        assertEquals(
            ActionResult.blocked("node_disabled"),
            run(AgentAction.TypeText(0, "x"), capture(ActionNode(isEditable = true, isEnabled = false))),
        )
        assertEquals(
            ActionResult.error("set_text_failed"),
            run(AgentAction.TypeText(0, "x"), capture(ActionNode(isEditable = true, setTextResult = false))),
        )
        assertEquals(
            ActionResult.error("submit_failed"),
            run(AgentAction.TypeText(0, "x", submit = true), capture(ActionNode(isEditable = true, imeResult = false))),
        )
        assertEquals(ActionStatus.NOT_FOUND, run(AgentAction.TypeText(3, "x"), capture()).status)
    }

    // --- scroll ---

    @Test
    fun `scrolls a container through the API`() {
        val list = ActionNode(isScrollable = true)
        assertEquals(ActionResult.OK, run(AgentAction.Scroll(ScrollDirection.DOWN, nodeId = 0), capture(list)))
        assertEquals(listOf(ScrollDirection.DOWN), list.scrolls)
        assertTrue(device.gestures.isEmpty())
    }

    @Test
    fun `swipes the container when it refuses to scroll`() {
        val list = ActionNode(isScrollable = true, scrollResult = false, bounds = Bounds(0, 1000, 1000, 2000))
        assertEquals(ActionResult.OK, run(AgentAction.Scroll(ScrollDirection.DOWN, nodeId = 0), capture(list)))
        assertEquals(ActionExecutor.swipe(Bounds(0, 1000, 1000, 2000), ScrollDirection.DOWN), device.gestures.single())
    }

    @Test
    fun `swipes the whole screen without a node`() {
        assertEquals(ActionResult.OK, run(AgentAction.Scroll(ScrollDirection.UP), capture()))
        assertEquals(ActionExecutor.swipe(screenBounds, ScrollDirection.UP), device.gestures.single())

        device.gestureResult = false
        assertEquals(ActionResult.error("gesture_failed"), run(AgentAction.Scroll(ScrollDirection.UP), capture()))
        assertEquals(ActionStatus.NOT_FOUND, run(AgentAction.Scroll(ScrollDirection.UP, nodeId = 9), capture()).status)
    }

    // --- global ---

    @Test
    fun `performs global actions`() {
        GlobalAction.entries.forEach {
            assertEquals(ActionResult.OK, run(AgentAction.Global(it), capture()))
        }
        assertEquals(GlobalAction.entries, device.globals)

        device.globalResult = false
        assertEquals(ActionResult.error("global_action_failed"), run(AgentAction.Global(GlobalAction.BACK), capture()))
    }

    // --- wait ---

    @Test
    fun `waits a fixed time, never longer than the cap`() {
        assertEquals(ActionResult.OK, run(AgentAction.Wait(ms = 500), capture()))
        assertEquals(ActionResult.OK, run(AgentAction.Wait(ms = 60_000), capture()))
        assertEquals(ActionResult.OK, run(AgentAction.Wait(ms = -5), capture()))
        assertEquals(listOf(500L, ActionExecutor.MAX_WAIT_MS, 0L), sleeps)
    }

    @Test
    fun `returns as soon as the awaited node appears`() {
        device.captures +=
            listOf(
                null,
                capture(ActionNode(text = "Yuklanmoqda")),
                capture(ActionNode(text = "Onam", viewId = "com.x:id/title")),
            )
        val result = run(AgentAction.Wait(until = NodeMatcher(textContains = "onam")), capture())
        assertEquals(ActionResult.OK, result)
        assertEquals(listOf(ActionExecutor.POLL_MS, ActionExecutor.POLL_MS), sleeps)
    }

    @Test
    fun `gives up when the awaited node never appears`() {
        device.fallback = capture(ActionNode(text = "Boshqa"))
        val result = run(AgentAction.Wait(ms = 1_000, until = NodeMatcher(viewId = "send")), capture())
        assertEquals(ActionResult.notFound("wait_timeout"), result)
        assertEquals(1_000L, sleeps.sum())
    }

    @Test
    fun `matches nodes by text, description or view id`() {
        fun m(
            matcher: NodeMatcher,
            text: String? = null,
            desc: String? = null,
            viewId: String? = null,
        ) = ActionExecutor.matches(matcher, text, desc, viewId)
        assertTrue(m(NodeMatcher(textContains = "SEND"), text = "Send message"))
        assertTrue(m(NodeMatcher(descContains = "yubor"), desc = "Yuborish"))
        assertTrue(m(NodeMatcher(viewId = "send"), viewId = "send"))
        assertTrue(m(NodeMatcher(textContains = "nope", viewId = "send"), viewId = "send"))
        assertFalse(m(NodeMatcher(viewId = "send"), viewId = "send_button"))
        assertFalse(m(NodeMatcher(textContains = "x")))
        assertFalse(m(NodeMatcher(), text = "anything"))
    }

    // --- geometry ---

    @Test
    fun `swipes reveal content in the named direction`() {
        val area = Bounds(0, 0, 1000, 1000)
        val (downFrom, downTo) = ActionExecutor.swipe(area, ScrollDirection.DOWN).points
        assertTrue(downFrom.y > downTo.y)
        val (upFrom, upTo) = ActionExecutor.swipe(area, ScrollDirection.UP).points
        assertTrue(upFrom.y < upTo.y)
        val (rightFrom, rightTo) = ActionExecutor.swipe(area, ScrollDirection.RIGHT).points
        assertTrue(rightFrom.x > rightTo.x)
        val (leftFrom, leftTo) = ActionExecutor.swipe(area, ScrollDirection.LEFT).points
        assertTrue(leftFrom.x < leftTo.x)
        assertEquals(ActionExecutor.SWIPE_MS, ActionExecutor.swipe(area, ScrollDirection.DOWN).durationMs)
    }

    @Test
    fun `aims at the visible part of a node that sticks out of the screen`() {
        assertEquals(PixelPoint(500f, 1950f), ActionExecutor.center(Bounds(0, 1900, 1000, 2400), screenBounds))
    }
}

private class FakeDevice : DeviceControl {
    val gestures = mutableListOf<Gesture>()
    val globals = mutableListOf<GlobalAction>()
    val captures = ArrayDeque<CapturedScreen?>()
    var fallback: CapturedScreen? = null
    var gestureResult = true
    var globalResult = true

    override fun capture(): CapturedScreen? = if (captures.isEmpty()) fallback else captures.removeFirst()

    override fun performGlobal(action: GlobalAction): Boolean {
        globals += action
        return globalResult
    }

    override fun performGesture(gesture: Gesture): Boolean {
        gestures += gesture
        return gestureResult
    }
}

private class ActionNode(
    override val packageName: String? = null,
    override val className: String? = "android.widget.TextView",
    override val text: String? = null,
    override val viewId: String? = null,
    override val bounds: Bounds = Bounds(0, 0, 1000, 200),
    override val isClickable: Boolean = false,
    override val isLongClickable: Boolean = false,
    override val isEditable: Boolean = false,
    override val isEnabled: Boolean = true,
    override val isScrollable: Boolean = false,
    override val isPassword: Boolean = false,
    override val children: List<UiNode> = emptyList(),
    private val alive: Boolean = true,
    private val clickResult: Boolean = true,
    private val setTextResult: Boolean = true,
    private val imeResult: Boolean = true,
    private val scrollResult: Boolean = true,
    focused: Boolean = false,
    private val focusOnClick: Boolean = true,
    private val focusResult: Boolean = false,
) : UiNode {
    override val contentDescription: String? = null
    override val hintText: String? = null
    override val isShowingHintText = false
    override val isVisibleToUser = true
    override var isFocused = focused
    override val isCheckable = false
    override val isChecked = false

    var clicks = 0
    var longClicks = 0
    var imeEnters = 0
    val typed = mutableListOf<String>()
    val scrolls = mutableListOf<ScrollDirection>()

    override fun refresh() = alive

    var focuses = 0

    override fun click(): Boolean {
        clicks++
        if (clickResult && focusOnClick) isFocused = true
        return clickResult
    }

    override fun focus(): Boolean {
        focuses++
        if (focusResult) isFocused = true
        return focusResult
    }

    override fun longClick(): Boolean {
        longClicks++
        return true
    }

    override fun setText(text: String): Boolean {
        if (setTextResult) typed += text
        return setTextResult
    }

    override fun imeEnter(): Boolean {
        imeEnters++
        return imeResult
    }

    override fun scroll(direction: ScrollDirection): Boolean {
        scrolls += direction
        return scrollResult
    }
}
