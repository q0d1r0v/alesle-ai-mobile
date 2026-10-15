package com.alesle.ai.agent.snapshot

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class SnapshotBuilderTest {
    private val screen = Bounds(0, 0, 1080, 2400)

    private val context =
        SnapshotContext(
            packageName = "org.telegram.messenger",
            activity = "org.telegram.ui.LaunchActivity",
            locale = "uz",
            orientation = Orientation.PORTRAIT,
            keyboardVisible = true,
            screen = screen,
        )

    private val builder = SnapshotBuilder(newSnapshotId = { "s-test" })

    private fun build(
        root: UiNode,
        b: SnapshotBuilder = builder,
    ) = b.build(root, context).snapshot

    private fun screenRoot(vararg children: UiNode) = FakeNode(className = "android.widget.FrameLayout", children = children.toList())

    @Test
    fun `passes the screen context through`() {
        val snapshot = build(screenRoot(FakeNode(text = "Salom")))
        assertEquals("s-test", snapshot.snapshotId)
        assertEquals("org.telegram.messenger", snapshot.packageName)
        assertEquals("org.telegram.ui.LaunchActivity", snapshot.activity)
        assertEquals("uz", snapshot.locale)
        assertEquals(Orientation.PORTRAIT, snapshot.orientation)
        assertTrue(snapshot.keyboardVisible)
        assertFalse(snapshot.truncated)
    }

    @Test
    fun `keeps visible interactive or text nodes and drops the rest`() {
        val snapshot =
            build(
                screenRoot(
                    FakeNode(text = "Chats"),
                    FakeNode(className = "android.widget.Button", isClickable = true),
                    FakeNode(className = "android.view.ViewGroup"),
                    FakeNode(text = "hidden", isVisibleToUser = false),
                    FakeNode(text = "zero size", bounds = Bounds(10, 10, 10, 50)),
                    FakeNode(text = "off screen", bounds = Bounds(0, 2500, 100, 2600)),
                    FakeNode(text = "   "),
                ),
            )
        assertEquals(listOf("Chats", null), snapshot.nodes.map { it.text })
        assertEquals("button", snapshot.nodes[1].role)
    }

    @Test
    fun `flattens in pre-order and numbers nodes from zero`() {
        val snapshot =
            build(
                screenRoot(
                    FakeNode(text = "a", children = listOf(FakeNode(text = "a1"), FakeNode(text = "a2"))),
                    FakeNode(text = "b"),
                ),
            )
        assertEquals(listOf("a", "a1", "a2", "b"), snapshot.nodes.map { it.text })
        assertEquals(listOf(0, 1, 2, 3), snapshot.nodes.map { it.id })
    }

    @Test
    fun `walks children of a hidden container`() {
        val snapshot = build(screenRoot(FakeNode(isVisibleToUser = false, children = listOf(FakeNode(text = "inside")))))
        assertEquals(listOf("inside"), snapshot.nodes.map { it.text })
    }

    @Test
    fun `masks password text but keeps the label`() {
        val node =
            build(
                screenRoot(FakeNode(text = "hunter2", contentDescription = "Parol", isEditable = true, isPassword = true)),
            ).nodes.single()
        assertEquals(SnapshotBuilder.PASSWORD_MASK, node.text)
        assertEquals("Parol", node.desc)
        assertTrue(node.password)
    }

    @Test
    fun `an empty password field stays empty`() {
        val node = build(screenRoot(FakeNode(isEditable = true, isPassword = true))).nodes.single()
        assertNull(node.text)
    }

    @Test
    fun `reports a placeholder as a description, not as typed text`() {
        val node =
            build(
                screenRoot(FakeNode(text = "Message", hintText = "Message", isShowingHintText = true, isEditable = true)),
            ).nodes.single()
        assertNull(node.text)
        assertEquals("Message", node.desc)
        assertEquals("textbox", node.role)
    }

    @Test
    fun `collapses whitespace and caps long text`() {
        val nodes =
            build(screenRoot(FakeNode(text = "  Salom\n\n  dunyo  "), FakeNode(text = "x".repeat(500)))).nodes
        assertEquals("Salom dunyo", nodes[0].text)
        assertEquals(SnapshotBuilder.MAX_TEXT_CHARS, nodes[1].text!!.length)
        assertTrue(nodes[1].text!!.endsWith("…"))
    }

    @Test
    fun `strips the package from view ids`() {
        val node = build(screenRoot(FakeNode(text = "Send", viewId = "org.telegram.messenger:id/send_button"))).nodes.single()
        assertEquals("send_button", node.viewId)
    }

    @Test
    fun `reports checked state only for checkable nodes`() {
        val nodes =
            build(
                screenRoot(
                    FakeNode(className = "android.widget.Switch", text = "Bluetooth", isCheckable = true, isChecked = true),
                    FakeNode(text = "label"),
                ),
            ).nodes
        assertEquals(true, nodes[0].checked)
        assertNull(nodes[1].checked)
    }

    @Test
    fun `derives roles from the node`() {
        fun role(node: FakeNode) = SnapshotBuilder.roleOf(node)
        assertEquals("textbox", role(FakeNode(className = "android.widget.EditText", isEditable = true)))
        assertEquals("switch", role(FakeNode(className = "android.widget.Switch", isCheckable = true)))
        assertEquals("radio", role(FakeNode(className = "android.widget.RadioButton", isCheckable = true)))
        assertEquals("checkbox", role(FakeNode(className = "android.widget.CheckBox", isCheckable = true)))
        assertEquals("button", role(FakeNode(className = "android.widget.ImageButton")))
        assertEquals("button", role(FakeNode(className = "android.widget.ImageView", isClickable = true)))
        assertEquals("image", role(FakeNode(className = "android.widget.ImageView")))
        assertEquals("list", role(FakeNode(className = "androidx.recyclerview.widget.RecyclerView", isScrollable = true)))
        assertEquals("button", role(FakeNode(className = "android.view.View", isLongClickable = true)))
        assertEquals("text", role(FakeNode(className = "android.widget.TextView")))
        assertEquals("text", role(FakeNode(className = null)))
    }

    @Test
    fun `over the cap keeps interactive nodes first, then those nearest the centre, in screen order`() {
        val small = SnapshotBuilder(maxNodes = 3, newSnapshotId = { "s" })
        val snapshot =
            build(
                screenRoot(
                    FakeNode(text = "far text", bounds = Bounds(0, 0, 100, 100)),
                    FakeNode(text = "far button", isClickable = true, bounds = Bounds(0, 0, 100, 100)),
                    FakeNode(text = "centre text", bounds = Bounds(490, 1150, 590, 1250)),
                    FakeNode(text = "near button", isClickable = true, bounds = Bounds(400, 1000, 680, 1400)),
                    FakeNode(text = "edge text", bounds = Bounds(0, 2300, 100, 2400)),
                ),
                small,
            )
        assertEquals(listOf("far button", "centre text", "near button"), snapshot.nodes.map { it.text })
        assertEquals(listOf(0, 1, 2), snapshot.nodes.map { it.id })
        assertTrue(snapshot.truncated)
    }

    @Test
    fun `a full screen of 300 nodes is not truncated`() {
        val snapshot = build(screenRoot(*Array(SnapshotBuilder.MAX_NODES) { FakeNode(text = "n$it") }))
        assertEquals(SnapshotBuilder.MAX_NODES, snapshot.nodes.size)
        assertFalse(snapshot.truncated)
    }

    @Test
    fun `stops walking a pathological tree and marks it truncated`() {
        val capped = SnapshotBuilder(maxTraversed = 10, newSnapshotId = { "s" })
        val snapshot = build(screenRoot(*Array(50) { FakeNode(text = "n$it") }), capped)
        assertEquals(9, snapshot.nodes.size) // the root counts as one visited node
        assertTrue(snapshot.truncated)
    }

    @Test
    fun `a deep tree does not overflow the stack`() {
        var node = FakeNode(text = "leaf")
        repeat(4_000) { node = FakeNode(children = listOf(node)) }
        assertEquals(listOf("leaf"), build(node).nodes.map { it.text })
    }

    @Test
    fun `screen hash ignores clock times and snapshot ids`() {
        val at941 = build(screenRoot(FakeNode(text = "Onam · 9:41"), FakeNode(contentDescription = "Sent at 21:05:33")))
        val at1012 =
            SnapshotBuilder(newSnapshotId = { "other" })
                .build(
                    screenRoot(FakeNode(text = "Onam · 10:12"), FakeNode(contentDescription = "Sent at 22:00:01")),
                    context,
                ).snapshot
        assertEquals(at941.screenHash, at1012.screenHash)
        assertEquals(40, at941.screenHash.length)
    }

    @Test
    fun `screen hash changes with content, layout, state or app`() {
        fun hashOf(
            node: FakeNode,
            ctx: SnapshotContext = context,
        ) = builder.build(screenRoot(node), ctx).snapshot.screenHash
        val base = FakeNode(text = "Salom", isEditable = true)
        val hash = hashOf(base)
        assertNotEquals(hash, hashOf(base.copy(text = "Salom!")))
        assertNotEquals(hash, hashOf(base.copy(text = "998901234567")))
        assertNotEquals(hash, hashOf(base.copy(bounds = Bounds(0, 100, 1080, 300))))
        assertNotEquals(hash, hashOf(base.copy(isFocused = true)))
        assertNotEquals(hash, hashOf(base, context.copy(packageName = "com.whatsapp")))
    }

    @Test
    fun `keeps the live node behind every snapshot id`() {
        val hidden = FakeNode(text = "hidden", isVisibleToUser = false)
        val send = FakeNode(text = "Send", isClickable = true)
        val title = FakeNode(text = "Onam")
        val captured = builder.build(screenRoot(title, hidden, send), context)
        assertEquals(listOf(title, send), captured.nodes)
        assertEquals(send, captured.node(1))
        assertNull(captured.node(2))
        assertNull(captured.node(-1))
        assertEquals(screen, captured.screen)
    }

    @Test
    fun `clean returns null for blank values`() {
        assertNull(SnapshotBuilder.clean(null))
        assertNull(SnapshotBuilder.clean(" \n "))
    }

    @Test
    fun `clean drops invisible direction marks`() {
        // Seen on a Xiaomi calculator: "\u202D7×6".
        assertEquals("7×6", SnapshotBuilder.clean("\u202D7×6"))
        assertEquals("+998 90", SnapshotBuilder.clean("\u2066+998\u2069 \u200E90"))
        assertNull(SnapshotBuilder.clean("\u202D"))
    }
}

private data class FakeNode(
    override val className: String? = "android.widget.TextView",
    override val text: String? = null,
    override val contentDescription: String? = null,
    override val hintText: String? = null,
    override val isShowingHintText: Boolean = false,
    override val viewId: String? = null,
    override val bounds: Bounds = Bounds(0, 0, 1080, 200),
    override val isVisibleToUser: Boolean = true,
    override val isClickable: Boolean = false,
    override val isLongClickable: Boolean = false,
    override val isEditable: Boolean = false,
    override val isEnabled: Boolean = true,
    override val isFocused: Boolean = false,
    override val isScrollable: Boolean = false,
    override val isCheckable: Boolean = false,
    override val isChecked: Boolean = false,
    override val isPassword: Boolean = false,
    override val children: List<UiNode> = emptyList(),
) : UiNode
