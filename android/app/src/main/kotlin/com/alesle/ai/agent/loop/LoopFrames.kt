package com.alesle.ai.agent.loop

import com.alesle.ai.agent.action.ActionResult
import com.alesle.ai.agent.action.Choice
import com.alesle.ai.agent.protocol.ActionJson
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

/** How the user wants sensitive steps handled (the app's "confirm every sensitive action" setting). */
enum class ConfirmPolicy(
    val wire: String,
) {
    CONFIRM("confirm"),
    COUNTDOWN("countdown"),
}

/** A sensitive step the server marked (alesle-ai-api docs/agent-protocol.md). */
data class Confirmation(
    val title: String,
    val detail: String,
    /** Payments, purchases, deletions: ask whatever the setting says. */
    val always: Boolean,
)

/** Frames the server sends; anything unknown or malformed decodes to null and is ignored. */
sealed interface ServerFrame {
    data class Accepted(
        val taskId: String,
    ) : ServerFrame

    data object Observe : ServerFrame

    data class Act(
        val stepId: String,
        val action: JSONObject,
        val say: String,
        val confirm: Confirmation?,
    ) : ServerFrame

    data class Ask(
        val askId: String,
        val question: String,
        val choices: List<Choice>,
    ) : ServerFrame

    data class Finish(
        val status: String,
        val reason: String?,
        val reply: String?,
    ) : ServerFrame

    data class Error(
        val code: String,
    ) : ServerFrame
}

object LoopFrames {
    fun decode(text: String): ServerFrame? =
        try {
            decode(JSONObject(text))
        } catch (e: JSONException) {
            null
        }

    private fun decode(json: JSONObject): ServerFrame? =
        when (json.optString("type")) {
            "task.accepted" -> json.text("taskId")?.let(ServerFrame::Accepted)
            "observe" -> ServerFrame.Observe
            "act" -> {
                val stepId = json.text("stepId")
                val action = json.optJSONObject("action")
                if (stepId == null || action == null) {
                    null
                } else {
                    ServerFrame.Act(stepId, action, json.text("say").orEmpty(), json.optJSONObject("confirm")?.let(::confirmation))
                }
            }
            "ask" -> {
                val askId = json.text("askId")
                val choices = json.optJSONArray("choices")?.let(::choices).orEmpty()
                if (askId == null || choices.isEmpty()) null else ServerFrame.Ask(askId, json.text("question").orEmpty(), choices)
            }
            "finish" -> json.text("status")?.let { ServerFrame.Finish(it, json.text("reason"), json.text("reply")) }
            "error" -> ServerFrame.Error(json.text("code") ?: "unknown")
            else -> null
        }

    private fun confirmation(json: JSONObject) =
        Confirmation(json.text("title").orEmpty(), json.text("detail").orEmpty(), json.optBoolean("always", false))

    private fun choices(array: JSONArray): List<Choice> =
        (0 until array.length()).mapNotNull { index ->
            val item = array.optJSONObject(index) ?: return@mapNotNull null
            val ref = item.text("ref") ?: return@mapNotNull null
            Choice(ref, item.text("label").orEmpty())
        }

    private fun JSONObject.text(key: String): String? = if (isNull(key)) null else (opt(key) as? String)

    // ── Phone → server ──────────────────────────────────────────────────────

    fun start(
        command: String,
        locale: String,
        policy: ConfirmPolicy,
    ): String =
        JSONObject()
            .put("type", "task.start")
            .put("command", command)
            .put("locale", locale)
            .put("policy", policy.wire)
            .toString()

    fun resume(taskId: String): String = JSONObject().put("type", "task.resume").put("taskId", taskId).toString()

    fun stop(): String = JSONObject().put("type", "task.stop").toString()

    /** [snapshot] is SnapshotBuilder JSON, or null when nothing is readable. */
    fun observation(
        stepId: String?,
        result: ActionResult?,
        snapshot: JSONObject?,
    ): String =
        JSONObject()
            .put("type", "observation")
            .put("stepId", stepId ?: JSONObject.NULL)
            .put("result", result?.let(ActionJson::encode) ?: JSONObject.NULL)
            .put("snapshot", snapshot ?: JSONObject.NULL)
            .toString()

    fun reply(
        askId: String,
        choice: String?,
    ): String =
        JSONObject()
            .put("type", "reply")
            .put("askId", askId)
            .put("choice", choice ?: JSONObject.NULL)
            .toString()
}
