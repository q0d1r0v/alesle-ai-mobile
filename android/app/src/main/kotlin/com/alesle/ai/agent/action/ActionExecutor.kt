package com.alesle.ai.agent.action

import com.alesle.ai.agent.snapshot.Bounds
import com.alesle.ai.agent.snapshot.CapturedScreen
import com.alesle.ai.agent.snapshot.ScrollDirection
import com.alesle.ai.agent.snapshot.UiNode

/**
 * Performs one [AgentAction] on the screen it was decided on (SOW 03 §4, §8).
 *
 * Node actions go through the accessibility API first and fall back to a
 * gesture at the node's centre. Two device-side rules hold whatever the
 * backend asks: the agent never types into password fields, and never taps
 * or types inside system permission dialogs (AC-AG-10).
 *
 * Blocking: run it on a worker thread, never on the main thread.
 */
class ActionExecutor(
    private val device: DeviceControl,
    private val sleep: (Long) -> Unit = Thread::sleep,
    private val now: () -> Long = System::currentTimeMillis,
) {
    fun execute(
        action: AgentAction,
        screen: CapturedScreen,
    ): ActionResult =
        when (action) {
            is AgentAction.Tap -> press(action.target, screen, long = false)
            is AgentAction.LongPress -> press(action.target, screen, long = true)
            is AgentAction.TypeText -> typeText(action, screen)
            is AgentAction.Scroll -> scroll(action, screen)
            is AgentAction.Global ->
                if (device.performGlobal(action.action)) ActionResult.OK else ActionResult.error("global_action_failed")
            is AgentAction.Wait -> wait(action)
        }

    private fun press(
        target: Target,
        screen: CapturedScreen,
        long: Boolean,
    ): ActionResult {
        if (isPermissionDialog(screen.snapshot.packageName)) return ActionResult.blocked(PERMISSION_DIALOG)
        val point =
            when (target) {
                is Target.Point -> {
                    if (target.x !in 0.0..1.0 || target.y !in 0.0..1.0) return ActionResult.error("point_out_of_range")
                    PixelPoint(
                        (screen.screen.left + target.x * (screen.screen.right - screen.screen.left)).toFloat(),
                        (screen.screen.top + target.y * (screen.screen.bottom - screen.screen.top)).toFloat(),
                    )
                }
                is Target.Node -> {
                    val node = resolve(target.id, screen) ?: return ActionResult.notFound(NODE_GONE)
                    if (isPermissionDialog(node.packageName)) return ActionResult.blocked(PERMISSION_DIALOG)
                    if (!node.isEnabled) return ActionResult.blocked("node_disabled")
                    val accepted = if (long) node.isLongClickable && node.longClick() else node.isClickable && node.click()
                    if (accepted) return ActionResult.OK
                    center(node.bounds, screen.screen)
                }
            }
        val gesture = Gesture(listOf(point), if (long) LONG_PRESS_MS else TAP_MS)
        return if (device.performGesture(gesture)) ActionResult.OK else ActionResult.error(GESTURE_FAILED)
    }

    private fun typeText(
        action: AgentAction.TypeText,
        screen: CapturedScreen,
    ): ActionResult {
        if (isPermissionDialog(screen.snapshot.packageName)) return ActionResult.blocked(PERMISSION_DIALOG)
        val node = resolve(action.nodeId, screen) ?: return ActionResult.notFound(NODE_GONE)
        if (isPermissionDialog(node.packageName)) return ActionResult.blocked(PERMISSION_DIALOG)
        // SOW 02 §4: the agent never enters passwords.
        if (node.isPassword) return ActionResult.blocked("password_field")
        if (!node.isEditable) return ActionResult.error("not_editable")
        if (!node.isEnabled) return ActionResult.blocked("node_disabled")
        if (!node.setText(action.text)) return ActionResult.error("set_text_failed")
        if (action.submit && !node.imeEnter()) return ActionResult.error("submit_failed")
        return ActionResult.OK
    }

    private fun scroll(
        action: AgentAction.Scroll,
        screen: CapturedScreen,
    ): ActionResult {
        val area =
            if (action.nodeId == null) {
                screen.screen
            } else {
                val node = resolve(action.nodeId, screen) ?: return ActionResult.notFound(NODE_GONE)
                if (node.scroll(action.direction)) return ActionResult.OK
                node.bounds
            }
        return if (device.performGesture(swipe(area, action.direction))) {
            ActionResult.OK
        } else {
            ActionResult.error(GESTURE_FAILED)
        }
    }

    private fun wait(action: AgentAction.Wait): ActionResult {
        val budget = action.ms.coerceIn(0, MAX_WAIT_MS)
        val matcher = action.until
        if (matcher == null) {
            sleep(budget)
            return ActionResult.OK
        }
        val deadline = now() + budget
        while (true) {
            val screen = device.capture()
            if (screen != null && screen.snapshot.nodes.any { matches(matcher, it.text, it.desc, it.viewId) }) {
                return ActionResult.OK
            }
            val left = deadline - now()
            if (left <= 0) return ActionResult.notFound("wait_timeout")
            sleep(minOf(POLL_MS, left))
        }
    }

    /** The live node behind a snapshot id, re-read so a vanished node is caught. */
    private fun resolve(
        id: Int,
        screen: CapturedScreen,
    ): UiNode? = screen.node(id)?.takeIf { it.refresh() }

    companion object {
        const val MAX_WAIT_MS = 3_000L
        const val POLL_MS = 150L
        const val TAP_MS = 50L
        const val LONG_PRESS_MS = 700L
        const val SWIPE_MS = 300L

        private const val NODE_GONE = "node_not_found"
        private const val PERMISSION_DIALOG = "permission_dialog"
        private const val GESTURE_FAILED = "gesture_failed"

        /** System UIs that grant permissions or install apps: the user decides there, not the agent. */
        val PERMISSION_PACKAGES =
            setOf(
                "com.android.permissioncontroller",
                "com.google.android.permissioncontroller",
                "com.android.packageinstaller",
                "com.google.android.packageinstaller",
            )

        private fun isPermissionDialog(packageName: String?) = packageName in PERMISSION_PACKAGES

        internal fun matches(
            matcher: NodeMatcher,
            text: String?,
            desc: String?,
            viewId: String?,
        ): Boolean {
            val checks =
                listOfNotNull(
                    matcher.textContains?.let { text?.contains(it, ignoreCase = true) == true },
                    matcher.descContains?.let { desc?.contains(it, ignoreCase = true) == true },
                    matcher.viewId?.let { viewId == it },
                )
            return checks.isNotEmpty() && checks.any { it }
        }

        /** The centre of the visible part of [bounds]. */
        internal fun center(
            bounds: Bounds,
            screen: Bounds,
        ): PixelPoint {
            val left = maxOf(bounds.left, screen.left)
            val top = maxOf(bounds.top, screen.top)
            val right = minOf(bounds.right, screen.right)
            val bottom = minOf(bounds.bottom, screen.bottom)
            return PixelPoint((left + right) / 2f, (top + bottom) / 2f)
        }

        /** A swipe across the middle 40 % of [area]; DOWN reveals content below. */
        internal fun swipe(
            area: Bounds,
            direction: ScrollDirection,
        ): Gesture {
            val width = (area.right - area.left).toFloat()
            val height = (area.bottom - area.top).toFloat()
            val cx = area.left + width / 2
            val cy = area.top + height / 2
            val (from, to) =
                when (direction) {
                    ScrollDirection.DOWN -> PixelPoint(cx, area.top + height * 0.7f) to PixelPoint(cx, area.top + height * 0.3f)
                    ScrollDirection.UP -> PixelPoint(cx, area.top + height * 0.3f) to PixelPoint(cx, area.top + height * 0.7f)
                    ScrollDirection.RIGHT -> PixelPoint(area.left + width * 0.7f, cy) to PixelPoint(area.left + width * 0.3f, cy)
                    ScrollDirection.LEFT -> PixelPoint(area.left + width * 0.3f, cy) to PixelPoint(area.left + width * 0.7f, cy)
                }
            return Gesture(listOf(from, to), SWIPE_MS)
        }
    }
}
