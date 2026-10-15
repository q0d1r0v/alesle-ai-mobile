package com.alesle.ai.agent.action

import com.alesle.ai.agent.snapshot.ScrollDirection

/**
 * The on-screen actions of SOW 03 §4. Intents (`launch_app`, `intent`) live in
 * the intent launcher; `ask_user`, `confirm` and `finish` belong to the
 * overlay and the backend.
 */
sealed interface AgentAction {
    data class Tap(
        val target: Target,
    ) : AgentAction

    data class LongPress(
        val target: Target,
    ) : AgentAction

    data class TypeText(
        val nodeId: Int,
        val text: String,
        val submit: Boolean = false,
    ) : AgentAction

    /** Without [nodeId] the whole screen is swiped. */
    data class Scroll(
        val direction: ScrollDirection,
        val nodeId: Int? = null,
    ) : AgentAction

    data class Global(
        val action: GlobalAction,
    ) : AgentAction

    /**
     * Waits [ms] (capped at [ActionExecutor.MAX_WAIT_MS]); with [until], returns
     * as soon as a matching node appears, or `not_found` when time runs out.
     */
    data class Wait(
        val ms: Long = ActionExecutor.MAX_WAIT_MS,
        val until: NodeMatcher? = null,
    ) : AgentAction
}

/** What a tap or long press lands on. */
sealed interface Target {
    /** A node from the snapshot the action was decided on. */
    data class Node(
        val id: Int,
    ) : Target

    /** A normalised point, `x` and `y` in [0, 1], as vision returns it (SOW 03 §3). */
    data class Point(
        val x: Double,
        val y: Double,
    ) : Target
}

enum class GlobalAction { BACK, HOME, RECENTS }

/** Matches a node by any of the given fields; text matches ignore case. */
data class NodeMatcher(
    val textContains: String? = null,
    val descContains: String? = null,
    val viewId: String? = null,
)

enum class ActionStatus(
    val wire: String,
) {
    OK("ok"),
    NOT_FOUND("not_found"),

    /** Refused on purpose by a device-side safety rule. */
    BLOCKED("blocked"),

    /** Several targets fit (two contacts named "Aziz"): the agent must ask, not guess (AC-AG-5). */
    AMBIGUOUS("ambiguous"),
    ERROR("error"),
}

/** One candidate the user can pick; [ref] is resent to choose it, [label] is shown. */
data class Choice(
    val ref: String,
    val label: String,
)

/**
 * [reason] is a snake_case code for the backend, never user-facing text.
 * [choices] is filled only for [ActionStatus.AMBIGUOUS].
 */
data class ActionResult(
    val status: ActionStatus,
    val reason: String? = null,
    val choices: List<Choice> = emptyList(),
) {
    companion object {
        val OK = ActionResult(ActionStatus.OK)

        fun ambiguous(
            reason: String,
            choices: List<Choice>,
        ) = ActionResult(ActionStatus.AMBIGUOUS, reason, choices)

        fun notFound(reason: String) = ActionResult(ActionStatus.NOT_FOUND, reason)

        fun blocked(reason: String) = ActionResult(ActionStatus.BLOCKED, reason)

        fun error(reason: String) = ActionResult(ActionStatus.ERROR, reason)
    }
}
