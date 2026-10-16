package com.alesle.ai.agent.snapshot

/** A rectangle in screen pixels. */
data class Bounds(
    val left: Int,
    val top: Int,
    val right: Int,
    val bottom: Int,
) {
    val isEmpty: Boolean get() = right <= left || bottom <= top

    fun intersects(other: Bounds): Boolean = left < other.right && other.left < right && top < other.bottom && other.top < bottom

    /** Squared distance from this rectangle's centre to [other]'s centre. */
    fun centerDistanceSquared(other: Bounds): Long {
        val dx = (left + right - other.left - other.right).toLong() / 2
        val dy = (top + bottom - other.top - other.bottom).toLong() / 2
        return dx * dx + dy * dy
    }
}

enum class ScrollDirection { UP, DOWN, LEFT, RIGHT }

/**
 * One accessibility node. [SnapshotBuilder] and the action executor work on
 * this instead of `AccessibilityNodeInfo` so every rule is unit-tested on
 * the JVM. Actions return whether the system accepted them; read-only fakes
 * can rely on the defaults.
 */
interface UiNode {
    val packageName: String? get() = null
    val className: String?
    val text: String?
    val contentDescription: String?

    /** What a widget says about its state ("Expanded", "On", "3 of 5"), when it says it. */
    val stateDescription: String? get() = null

    /** True when an expandable section is open, false when closed, null when it is neither. */
    val expanded: Boolean? get() = null

    /** Placeholder text, when [isShowingHintText] is true. */
    val hintText: String?
    val isShowingHintText: Boolean

    /** Fully-qualified resource id, e.g. `org.telegram.messenger:id/send_button`. */
    val viewId: String?
    val bounds: Bounds
    val isVisibleToUser: Boolean
    val isClickable: Boolean
    val isLongClickable: Boolean
    val isEditable: Boolean
    val isEnabled: Boolean
    val isFocused: Boolean
    val isScrollable: Boolean
    val isCheckable: Boolean
    val isChecked: Boolean
    val isPassword: Boolean
    val children: List<UiNode>

    /** Re-reads the node; false when it has left the screen. */
    fun refresh(): Boolean = true

    fun click(): Boolean = false

    fun longClick(): Boolean = false

    /** Gives the node input focus. */
    fun focus(): Boolean = false

    fun setText(text: String): Boolean = false

    /** Presses the keyboard's action key (send, search, done…) for this field. */
    fun imeEnter(): Boolean = false

    /** [ScrollDirection.DOWN] reveals content below, like a finger swiping up. */
    fun scroll(direction: ScrollDirection): Boolean = false
}
