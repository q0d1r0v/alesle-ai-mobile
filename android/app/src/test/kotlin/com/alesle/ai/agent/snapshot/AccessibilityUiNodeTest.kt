package com.alesle.ai.agent.snapshot

import android.graphics.Rect
import android.view.accessibility.AccessibilityNodeInfo
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
    fun `an empty node has no text`() {
        val node = AccessibilityUiNode(AccessibilityNodeInfo())
        assertNull(node.className)
        assertNull(node.text)
        assertNull(node.contentDescription)
        assertNull(node.hintText)
        assertNull(node.viewId)
        assertFalse(node.isChecked)
    }
}
