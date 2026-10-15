package com.alesle.ai.agent.snapshot

import android.graphics.Rect
import android.os.Build
import android.os.Bundle
import android.view.accessibility.AccessibilityNodeInfo
import android.view.accessibility.AccessibilityNodeInfo.AccessibilityAction

/** [UiNode] backed by a live `AccessibilityNodeInfo`. */
class AccessibilityUiNode(
    private val info: AccessibilityNodeInfo,
) : UiNode {
    override val packageName: String? get() = info.packageName?.toString()
    override val className: String? get() = info.className?.toString()
    override val text: String? get() = info.text?.toString()
    override val contentDescription: String? get() = info.contentDescription?.toString()
    override val hintText: String? get() = info.hintText?.toString()
    override val isShowingHintText: Boolean get() = info.isShowingHintText
    override val viewId: String? get() = info.viewIdResourceName
    override val bounds: Bounds
        get() {
            val rect = Rect()
            info.getBoundsInScreen(rect)
            return Bounds(rect.left, rect.top, rect.right, rect.bottom)
        }
    override val isVisibleToUser: Boolean get() = info.isVisibleToUser
    override val isClickable: Boolean get() = info.isClickable
    override val isLongClickable: Boolean get() = info.isLongClickable
    override val isEditable: Boolean get() = info.isEditable
    override val isEnabled: Boolean get() = info.isEnabled
    override val isFocused: Boolean get() = info.isFocused
    override val isScrollable: Boolean get() = info.isScrollable
    override val isCheckable: Boolean get() = info.isCheckable
    override val isChecked: Boolean
        get() =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.BAKLAVA) {
                // A partially checked box (tri-state) is reported as not checked.
                info.checked == AccessibilityNodeInfo.CHECKED_STATE_TRUE
            } else {
                @Suppress("DEPRECATION")
                info.isChecked
            }
    override val isPassword: Boolean get() = info.isPassword
    override val children: List<UiNode>
        get() = (0 until info.childCount).mapNotNull { info.getChild(it) }.map(::AccessibilityUiNode)

    override fun refresh(): Boolean = info.refresh()

    override fun click(): Boolean = info.performAction(AccessibilityNodeInfo.ACTION_CLICK)

    override fun longClick(): Boolean = info.performAction(AccessibilityNodeInfo.ACTION_LONG_CLICK)

    override fun setText(text: String): Boolean {
        val args = Bundle().apply { putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, text) }
        return info.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)
    }

    override fun imeEnter(): Boolean = info.performAction(AccessibilityAction.ACTION_IME_ENTER.id)

    /**
     * Prefers the directional action; containers that only declare
     * forward/backward get those (forward = down or right).
     */
    override fun scroll(direction: ScrollDirection): Boolean {
        val directional =
            when (direction) {
                ScrollDirection.UP -> AccessibilityAction.ACTION_SCROLL_UP
                ScrollDirection.DOWN -> AccessibilityAction.ACTION_SCROLL_DOWN
                ScrollDirection.LEFT -> AccessibilityAction.ACTION_SCROLL_LEFT
                ScrollDirection.RIGHT -> AccessibilityAction.ACTION_SCROLL_RIGHT
            }
        if (info.actionList.contains(directional)) return info.performAction(directional.id)
        val linear =
            when (direction) {
                ScrollDirection.DOWN, ScrollDirection.RIGHT -> AccessibilityNodeInfo.ACTION_SCROLL_FORWARD
                ScrollDirection.UP, ScrollDirection.LEFT -> AccessibilityNodeInfo.ACTION_SCROLL_BACKWARD
            }
        return info.performAction(linear)
    }
}
