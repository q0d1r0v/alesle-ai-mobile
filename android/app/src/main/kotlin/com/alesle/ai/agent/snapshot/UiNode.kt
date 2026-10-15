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

/**
 * Read-only view of one accessibility node. [SnapshotBuilder] works on this
 * instead of `AccessibilityNodeInfo` so every rule is unit-tested on the JVM.
 */
interface UiNode {
    val className: String?
    val text: String?
    val contentDescription: String?

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
}
