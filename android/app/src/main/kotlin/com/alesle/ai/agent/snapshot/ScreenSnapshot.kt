package com.alesle.ai.agent.snapshot

import org.json.JSONArray
import org.json.JSONObject

/**
 * What the agent sees on one screen (SOW 03 §2.1). Lives in memory for the
 * duration of a task only: never written to disk, logs or the database (A8).
 */
data class ScreenSnapshot(
    val snapshotId: String,
    val packageName: String,
    val activity: String?,
    val screenHash: String,
    val locale: String,
    val orientation: Orientation,
    val nodes: List<SnapshotNode>,
    val keyboardVisible: Boolean,
    val truncated: Boolean,
) {
    fun toJson(): JSONObject =
        JSONObject()
            .put("snapshotId", snapshotId)
            .put("package", packageName)
            .put("activity", activity ?: JSONObject.NULL)
            .put("screenHash", screenHash)
            .put("locale", locale)
            .put("orientation", orientation.wire)
            .put("nodes", JSONArray(nodes.map(SnapshotNode::toJson)))
            .put("keyboardVisible", keyboardVisible)
            .put("truncated", truncated)
}

/**
 * A snapshot together with the live nodes behind it: `nodes[i]` is the node
 * the snapshot calls `id = i`. Actions resolve node ids through this.
 */
class CapturedScreen(
    val snapshot: ScreenSnapshot,
    val nodes: List<UiNode>,
    /** The display area the snapshot was taken against. */
    val screen: Bounds,
) {
    fun node(id: Int): UiNode? = nodes.getOrNull(id)
}

enum class Orientation(
    val wire: String,
) {
    PORTRAIT("portrait"),
    LANDSCAPE("landscape"),
}

/**
 * One visible node. [id] is stable only within its snapshot; actions refer to
 * nodes by it. [checked] is null for nodes that cannot be checked.
 */
data class SnapshotNode(
    val id: Int,
    val role: String,
    val text: String?,
    val desc: String?,
    val viewId: String?,
    val bounds: Bounds,
    val clickable: Boolean,
    val editable: Boolean,
    val enabled: Boolean,
    val focused: Boolean,
    val scrollable: Boolean,
    val checked: Boolean?,
    val password: Boolean,
) {
    fun toJson(): JSONObject =
        JSONObject()
            .put("id", id)
            .put("role", role)
            .put("text", text ?: JSONObject.NULL)
            .put("desc", desc ?: JSONObject.NULL)
            .put("viewId", viewId ?: JSONObject.NULL)
            .put("bounds", JSONArray(listOf(bounds.left, bounds.top, bounds.right, bounds.bottom)))
            .put("clickable", clickable)
            .put("editable", editable)
            .put("enabled", enabled)
            .put("focused", focused)
            .put("scrollable", scrollable)
            .put("checked", checked ?: JSONObject.NULL)
            .put("password", password)
}
