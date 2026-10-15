package com.alesle.ai.agent.snapshot

import java.security.MessageDigest
import java.util.UUID

/** Facts about the screen that do not come from the node tree. */
data class SnapshotContext(
    val packageName: String,
    val activity: String?,
    val locale: String,
    val orientation: Orientation,
    val keyboardVisible: Boolean,
    /** The display area; nodes outside it are not visible. */
    val screen: Bounds,
)

/**
 * Turns an accessibility tree into a flat, bounded [ScreenSnapshot]
 * (SOW 03 §2.1):
 * - keeps only visible nodes that are interactive or carry text;
 * - masks password text;
 * - caps the list at [maxNodes], preferring interactive nodes near the
 *   centre of the screen, and marks the snapshot `truncated`;
 * - hashes the screen without clock times, so an unchanged screen keeps
 *   its hash and the backend can skip a model call.
 */
class SnapshotBuilder(
    private val maxNodes: Int = MAX_NODES,
    private val maxTraversed: Int = MAX_TRAVERSED,
    private val newSnapshotId: () -> String = { "s-${UUID.randomUUID()}" },
) {
    fun build(
        root: UiNode,
        context: SnapshotContext,
    ): CapturedScreen {
        val (candidates, traversalCut) = collect(root, context.screen)
        val kept =
            if (candidates.size <= maxNodes) {
                candidates
            } else {
                candidates
                    .sortedWith(
                        compareBy<Candidate> { !it.interactive }
                            .thenBy { it.node.bounds.centerDistanceSquared(context.screen) },
                    ).take(maxNodes)
                    .sortedBy { it.order }
            }
        val nodes = kept.mapIndexed { index, candidate -> toSnapshotNode(index, candidate.node) }
        val snapshot =
            ScreenSnapshot(
                snapshotId = newSnapshotId(),
                packageName = context.packageName,
                activity = context.activity,
                screenHash = screenHash(context.packageName, nodes),
                locale = context.locale,
                orientation = context.orientation,
                nodes = nodes,
                keyboardVisible = context.keyboardVisible,
                truncated = traversalCut || candidates.size > maxNodes,
            )
        return CapturedScreen(snapshot, kept.map { it.node }, context.screen)
    }

    private class Candidate(
        val node: UiNode,
        val order: Int,
        val interactive: Boolean,
    )

    /** Pre-order walk without recursion: deep trees cannot overflow the stack. */
    private fun collect(
        root: UiNode,
        screen: Bounds,
    ): Pair<List<Candidate>, Boolean> {
        val result = mutableListOf<Candidate>()
        val stack = ArrayDeque<UiNode>().apply { addLast(root) }
        var visited = 0
        while (stack.isNotEmpty()) {
            if (visited == maxTraversed) return result to true
            val node = stack.removeLast()
            visited++
            if (isShown(node, screen)) {
                val interactive = isInteractive(node)
                if (interactive || hasText(node)) result += Candidate(node, result.size, interactive)
            }
            node.children.asReversed().forEach(stack::addLast)
        }
        return result to false
    }

    private fun isShown(
        node: UiNode,
        screen: Bounds,
    ): Boolean = node.isVisibleToUser && !node.bounds.isEmpty && node.bounds.intersects(screen)

    private fun isInteractive(node: UiNode): Boolean =
        node.isClickable || node.isLongClickable || node.isEditable || node.isScrollable || node.isCheckable

    private fun hasText(node: UiNode): Boolean = !node.text.isNullOrBlank() || !node.contentDescription.isNullOrBlank()

    private fun toSnapshotNode(
        id: Int,
        node: UiNode,
    ): SnapshotNode {
        // An empty field shows its placeholder as text; report it as a
        // description so the agent does not mistake it for typed input.
        val text = if (node.isShowingHintText) null else clean(node.text)
        val desc = clean(node.contentDescription) ?: if (node.isShowingHintText) clean(node.hintText) else null
        return SnapshotNode(
            id = id,
            role = roleOf(node),
            text = if (node.isPassword && text != null) PASSWORD_MASK else text,
            desc = desc,
            viewId = node.viewId?.substringAfter(":id/"),
            bounds = node.bounds,
            clickable = node.isClickable || node.isLongClickable,
            editable = node.isEditable,
            enabled = node.isEnabled,
            focused = node.isFocused,
            scrollable = node.isScrollable,
            checked = if (node.isCheckable) node.isChecked else null,
            password = node.isPassword,
        )
    }

    companion object {
        /** SOW 03 §2.1: ~300 nodes keeps a snapshot near 6k tokens. */
        const val MAX_NODES = 300

        /** Bounds the walk itself, so a pathological tree cannot stall a step. */
        const val MAX_TRAVERSED = 5_000

        const val MAX_TEXT_CHARS = 200
        const val PASSWORD_MASK = "•••"

        private val WHITESPACE = Regex("\\s+")

        /** 9:41, 21:05:33, 9:41 PM, 9:41 p.m. */
        private val CLOCK_TIME = Regex("\\b\\d{1,2}:\\d{2}(?::\\d{2})?(?:\\s?[AaPp]\\.?[Mm]\\.?)?(?!\\w)")

        internal fun clean(value: String?): String? {
            val collapsed = value?.replace(WHITESPACE, " ")?.trim()
            if (collapsed.isNullOrEmpty()) return null
            return if (collapsed.length <= MAX_TEXT_CHARS) collapsed else collapsed.take(MAX_TEXT_CHARS - 1) + "…"
        }

        internal fun roleOf(node: UiNode): String {
            val cls = node.className.orEmpty().substringAfterLast('.')
            return when {
                node.isEditable -> "textbox"
                cls.contains("Switch") -> "switch"
                node.isCheckable && cls.contains("Radio") -> "radio"
                node.isCheckable -> "checkbox"
                cls.contains("Button") -> "button"
                cls.contains("Image") -> if (node.isClickable) "button" else "image"
                node.isScrollable -> "list"
                node.isClickable || node.isLongClickable -> "button"
                else -> "text"
            }
        }

        internal fun screenHash(
            packageName: String,
            nodes: List<SnapshotNode>,
        ): String {
            val digest = MessageDigest.getInstance("SHA-1")
            digest.update(packageName.toByteArray())
            for (node in nodes) {
                val line =
                    listOf(
                        node.role,
                        node.viewId,
                        node.text?.replace(CLOCK_TIME, "#"),
                        node.desc?.replace(CLOCK_TIME, "#"),
                        node.bounds,
                        node.clickable,
                        node.editable,
                        node.enabled,
                        node.focused,
                        node.scrollable,
                        node.checked,
                    ).joinToString("\u001f")
                digest.update('\n'.code.toByte())
                digest.update(line.toByteArray())
            }
            return digest.digest().joinToString("") { "%02x".format(it) }
        }
    }
}
