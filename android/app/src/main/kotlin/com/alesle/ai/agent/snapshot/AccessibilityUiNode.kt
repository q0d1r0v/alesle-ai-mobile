package com.alesle.ai.agent.snapshot

import android.graphics.Rect
import android.os.Build
import android.view.accessibility.AccessibilityNodeInfo

/** [UiNode] backed by a live `AccessibilityNodeInfo`. */
class AccessibilityUiNode(
    private val info: AccessibilityNodeInfo,
) : UiNode {
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
}
