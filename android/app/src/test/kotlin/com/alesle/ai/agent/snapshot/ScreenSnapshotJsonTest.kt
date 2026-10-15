package com.alesle.ai.agent.snapshot

import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

/** org.json is part of the Android framework, so this runs under Robolectric. */
@RunWith(RobolectricTestRunner::class)
class ScreenSnapshotJsonTest {
    private val node =
        SnapshotNode(
            id = 17,
            role = "button",
            text = "Send",
            desc = null,
            viewId = "send_button",
            bounds = Bounds(944, 1820, 1060, 1920),
            clickable = true,
            editable = false,
            enabled = true,
            focused = false,
            scrollable = false,
            checked = null,
            password = false,
        )

    private val snapshot =
        ScreenSnapshot(
            snapshotId = "s-1",
            packageName = "org.telegram.messenger",
            activity = null,
            screenHash = "abc",
            locale = "uz",
            orientation = Orientation.PORTRAIT,
            nodes = listOf(node),
            keyboardVisible = true,
            truncated = false,
        )

    @Test
    fun `serialises the snapshot in the SOW wire format`() {
        val json = snapshot.toJson()
        assertEquals("s-1", json.getString("snapshotId"))
        assertEquals("org.telegram.messenger", json.getString("package"))
        assertTrue(json.isNull("activity"))
        assertEquals("abc", json.getString("screenHash"))
        assertEquals("uz", json.getString("locale"))
        assertEquals("portrait", json.getString("orientation"))
        assertTrue(json.getBoolean("keyboardVisible"))
        assertFalse(json.getBoolean("truncated"))
        assertEquals(1, json.getJSONArray("nodes").length())
    }

    @Test
    fun `serialises a node with explicit nulls and an array of bounds`() {
        val json: JSONObject = node.toJson()
        assertEquals(17, json.getInt("id"))
        assertEquals("button", json.getString("role"))
        assertEquals("Send", json.getString("text"))
        assertTrue(json.isNull("desc"))
        assertEquals("send_button", json.getString("viewId"))
        assertEquals("[944,1820,1060,1920]", json.getJSONArray("bounds").toString())
        assertTrue(json.getBoolean("clickable"))
        assertTrue(json.isNull("checked"))
        assertFalse(json.getBoolean("password"))
    }

    @Test
    fun `serialises present optional values`() {
        val json = snapshot.copy(activity = "LaunchActivity", orientation = Orientation.LANDSCAPE).toJson()
        assertEquals("LaunchActivity", json.getString("activity"))
        assertEquals("landscape", json.getString("orientation"))
        val nodeJson = node.copy(desc = "Yuborish", viewId = null, checked = true).toJson()
        assertEquals("Yuborish", nodeJson.getString("desc"))
        assertTrue(nodeJson.isNull("viewId"))
        assertTrue(nodeJson.getBoolean("checked"))
    }
}
