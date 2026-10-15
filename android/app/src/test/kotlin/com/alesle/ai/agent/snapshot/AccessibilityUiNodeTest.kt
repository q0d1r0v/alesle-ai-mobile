package com.alesle.ai.agent.snapshot

import android.graphics.Rect
import android.os.Bundle
import android.view.accessibility.AccessibilityNodeInfo
import android.view.accessibility.AccessibilityNodeInfo.AccessibilityAction
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import io.mockk.verify
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
class AccessibilityUiNodeTest {
    @Suppress("DEPRECATION")
    private fun info(): AccessibilityNodeInfo =
        AccessibilityNodeInfo().apply {
            packageName = "com.example"
            className = "android.widget.EditText"
            text = "hunter2"
            contentDescription = "Parol"
            hintText = "Parolni kiriting"
            viewIdResourceName = "com.example:id/password"
            setBoundsInScreen(Rect(10, 20, 300, 120))
            isVisibleToUser = true
            isClickable = true
            isLongClickable = true
            isEditable = true
            isEnabled = true
            isFocused = true
            isScrollable = true
            isCheckable = true
            isChecked = true
            isPassword = true
        }

    @Test
    fun `reads every field from the framework node`() {
        val node = AccessibilityUiNode(info())
        assertEquals("com.example", node.packageName)
        assertEquals("android.widget.EditText", node.className)
        assertEquals("hunter2", node.text)
        assertEquals("Parol", node.contentDescription)
        assertEquals("Parolni kiriting", node.hintText)
        assertFalse(node.isShowingHintText)
        assertEquals("com.example:id/password", node.viewId)
        assertEquals(Bounds(10, 20, 300, 120), node.bounds)
        assertTrue(node.isVisibleToUser)
        assertTrue(node.isClickable)
        assertTrue(node.isLongClickable)
        assertTrue(node.isEditable)
        assertTrue(node.isEnabled)
        assertTrue(node.isFocused)
        assertTrue(node.isScrollable)
        assertTrue(node.isCheckable)
        assertTrue(node.isChecked)
        assertTrue(node.isPassword)
        assertEquals(emptyList<UiNode>(), node.children)
    }

    @Test
    @Config(sdk = [35])
    fun `reads the legacy checked flag before Android 16`() {
        assertTrue(AccessibilityUiNode(info()).isChecked)
    }

    @Test
    fun `forwards actions to the framework node`() {
        val info = mockk<AccessibilityNodeInfo>(relaxed = true)
        every { info.performAction(any()) } returns true
        every { info.performAction(any(), any()) } returns true
        every { info.refresh() } returns false
        val node = AccessibilityUiNode(info)

        assertFalse(node.refresh())
        assertTrue(node.click())
        assertTrue(node.longClick())
        assertTrue(node.imeEnter())
        assertTrue(node.focus())
        val args = slot<Bundle>()
        assertTrue(node.setText("Salom"))
        verify {
            info.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            info.performAction(AccessibilityNodeInfo.ACTION_LONG_CLICK)
            info.performAction(AccessibilityAction.ACTION_IME_ENTER.id)
            info.performAction(AccessibilityNodeInfo.ACTION_FOCUS)
            info.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, capture(args))
        }
        assertEquals("Salom", args.captured.getCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE))
    }

    @Test
    fun `scrolls with the directional action when the node declares it`() {
        val info = mockk<AccessibilityNodeInfo>(relaxed = true)
        every { info.actionList } returns listOf(AccessibilityAction.ACTION_SCROLL_DOWN, AccessibilityAction.ACTION_SCROLL_RIGHT)
        every { info.performAction(any()) } returns true
        val node = AccessibilityUiNode(info)
        assertTrue(node.scroll(ScrollDirection.DOWN))
        assertTrue(node.scroll(ScrollDirection.RIGHT))
        verify {
            info.performAction(AccessibilityAction.ACTION_SCROLL_DOWN.id)
            info.performAction(AccessibilityAction.ACTION_SCROLL_RIGHT.id)
        }
    }

    @Test
    fun `falls back to forward and backward scrolling`() {
        val info = mockk<AccessibilityNodeInfo>(relaxed = true)
        every { info.actionList } returns emptyList()
        every { info.performAction(any()) } returns true
        val node = AccessibilityUiNode(info)
        ScrollDirection.entries.forEach { node.scroll(it) }
        verify(exactly = 2) { info.performAction(AccessibilityNodeInfo.ACTION_SCROLL_FORWARD) }
        verify(exactly = 2) { info.performAction(AccessibilityNodeInfo.ACTION_SCROLL_BACKWARD) }
        verify(exactly = 0) { info.performAction(AccessibilityAction.ACTION_SCROLL_UP.id) }
    }

    @Test
    fun `an empty node has no text`() {
        val node = AccessibilityUiNode(AccessibilityNodeInfo())
        assertNull(node.packageName)
        assertNull(node.className)
        assertNull(node.text)
        assertNull(node.contentDescription)
        assertNull(node.hintText)
        assertNull(node.viewId)
        assertFalse(node.isChecked)
    }
}
