package com.alesle.ai.agent.protocol

import com.alesle.ai.agent.action.ActionResult
import com.alesle.ai.agent.action.AgentAction
import com.alesle.ai.agent.action.GlobalAction
import com.alesle.ai.agent.action.NodeMatcher
import com.alesle.ai.agent.action.Target
import com.alesle.ai.agent.intent.IntentAction
import com.alesle.ai.agent.intent.Recipient
import com.alesle.ai.agent.snapshot.ScrollDirection
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

/** An action decoded from the wire: either on screen or through a system intent. */
sealed interface DecodedAction {
    data class Screen(
        val action: AgentAction,
    ) : DecodedAction

    data class Intent(
        val action: IntentAction,
    ) : DecodedAction

    /**
     * The user's turn: a permission dialog, a lock screen, a password. The
     * loop waits, hands off the screen, until it changes or [timeoutMs] passes.
     */
    data class WaitForUser(
        val timeoutMs: Long,
    ) : DecodedAction {
        companion object {
            const val DEFAULT_MS = 60_000L
            const val MIN_MS = 5_000L
            const val MAX_MS = 120_000L
        }
    }
}

/** The action JSON was malformed; [reason] is a snake_case code for the backend. */
class ActionDecodeException(
    val reason: String,
) : IllegalArgumentException(reason)

/**
 * The wire format of SOW 03 §4 actions, one JSON object per action:
 *
 * ```
 * {"type":"tap","nodeId":4}                {"type":"tap","point":[0.5,0.8]}
 * {"type":"long_press","nodeId":4}         {"type":"type_text","nodeId":2,"text":"salom","submit":true}
 * {"type":"scroll","direction":"down"}     {"type":"back"} {"type":"home"} {"type":"recents"}
 * {"type":"wait","ms":1500,"until":{"textContains":"Yuborildi"}}
 * {"type":"wait_for_user","timeoutMs":60000}
 * {"type":"launch_app","package":"org.telegram.messenger"}   {"type":"launch_app","name":"Telegram"}
 * {"type":"intent","kind":"call","to":{"contact":"Aziz"}}    // or {"phone":"+998…"} / {"ref":"contact:12"}
 * {"type":"intent","kind":"sms","to":{…},"text":"…"}
 * {"type":"intent","kind":"alarm","hour":7,"minute":30,"label":"…","days":[2,3]}
 * {"type":"intent","kind":"calendar_event","title":"…","begin":1760000000000,"end":…,"location":"…"}
 * {"type":"intent","kind":"web_search"|"maps_search"|"youtube_search","query":"…"}
 * {"type":"intent","kind":"share_text","text":"…","package":"…"}
 * ```
 *
 * `ask_user`, `confirm` and `finish` never reach the device executor.
 */
object ActionJson {
    fun decode(json: String): DecodedAction =
        try {
            decode(JSONObject(json))
        } catch (e: JSONException) {
            throw ActionDecodeException("invalid_json")
        }

    fun decode(json: JSONObject): DecodedAction =
        when (val type = json.requiredString("type")) {
            "tap" -> DecodedAction.Screen(AgentAction.Tap(target(json)))
            "long_press" -> DecodedAction.Screen(AgentAction.LongPress(target(json)))
            "type_text" ->
                DecodedAction.Screen(
                    AgentAction.TypeText(json.requiredInt("nodeId"), json.requiredString("text"), json.optBoolean("submit", false)),
                )
            "scroll" -> DecodedAction.Screen(AgentAction.Scroll(direction(json), json.optionalInt("nodeId")))
            "back" -> DecodedAction.Screen(AgentAction.Global(GlobalAction.BACK))
            "home" -> DecodedAction.Screen(AgentAction.Global(GlobalAction.HOME))
            "recents" -> DecodedAction.Screen(AgentAction.Global(GlobalAction.RECENTS))
            "wait" -> DecodedAction.Screen(wait(json))
            "wait_for_user" ->
                DecodedAction.WaitForUser(
                    (json.optionalLong("timeoutMs") ?: DecodedAction.WaitForUser.DEFAULT_MS)
                        .coerceIn(DecodedAction.WaitForUser.MIN_MS, DecodedAction.WaitForUser.MAX_MS),
                )
            "launch_app" -> {
                val packageName = json.optionalString("package")
                val name = json.optionalString("name")
                if (packageName == null && name == null) throw ActionDecodeException("app_not_specified")
                DecodedAction.Intent(IntentAction.LaunchApp(packageName, name))
            }
            "intent" -> DecodedAction.Intent(intent(json))
            else -> throw ActionDecodeException("unknown_action:$type")
        }

    fun encode(result: ActionResult): JSONObject {
        val json = JSONObject().put("status", result.status.wire)
        result.reason?.let { json.put("reason", it) }
        if (result.choices.isNotEmpty()) {
            json.put("choices", JSONArray(result.choices.map { JSONObject().put("ref", it.ref).put("label", it.label) }))
        }
        return json
    }

    private fun target(json: JSONObject): Target {
        json.optionalInt("nodeId")?.let { return Target.Node(it) }
        val point = json.optJSONArray("point") ?: throw ActionDecodeException("target_missing")
        if (point.length() != 2) throw ActionDecodeException("invalid_point")
        val x = point.optDouble(0)
        val y = point.optDouble(1)
        if (x.isNaN() || y.isNaN()) throw ActionDecodeException("invalid_point")
        return Target.Point(x, y)
    }

    private fun direction(json: JSONObject): ScrollDirection {
        val wire = json.requiredString("direction")
        return ScrollDirection.entries.firstOrNull { it.name.equals(wire, ignoreCase = true) }
            ?: throw ActionDecodeException("invalid_direction")
    }

    private fun wait(json: JSONObject): AgentAction.Wait {
        val until =
            json.optJSONObject("until")?.let {
                NodeMatcher(it.optionalString("textContains"), it.optionalString("descContains"), it.optionalString("viewId"))
            }
        return AgentAction.Wait(json.optionalLong("ms") ?: AgentAction.Wait().ms, until)
    }

    private fun intent(json: JSONObject): IntentAction =
        when (val kind = json.requiredString("kind")) {
            "call" -> IntentAction.Call(recipient(json))
            "sms" -> IntentAction.Sms(recipient(json), json.requiredString("text"))
            "alarm" -> {
                val days = json.optJSONArray("days")?.let { array -> List(array.length()) { array.getInt(it) } }.orEmpty()
                IntentAction.Alarm(json.requiredInt("hour"), json.requiredInt("minute"), json.optionalString("label"), days)
            }
            "calendar_event" ->
                IntentAction.CalendarEvent(
                    json.requiredString("title"),
                    json.requiredLong("begin"),
                    json.requiredLong("end"),
                    json.optionalString("location"),
                )
            "web_search" -> IntentAction.WebSearch(json.requiredString("query"))
            "maps_search" -> IntentAction.MapsSearch(json.requiredString("query"))
            "youtube_search" -> IntentAction.YouTubeSearch(json.requiredString("query"))
            "share_text" -> IntentAction.ShareText(json.requiredString("text"), json.optionalString("package"))
            else -> throw ActionDecodeException("unknown_intent:$kind")
        }

    private fun recipient(json: JSONObject): Recipient {
        val to = json.optJSONObject("to") ?: throw ActionDecodeException("missing_field:to")
        to.optionalString("phone")?.let { return Recipient.Phone(it) }
        to.optionalString("contact")?.let { return Recipient.ContactName(it) }
        to.optionalString("ref")?.let { return Recipient.ContactRef(it) }
        throw ActionDecodeException("invalid_recipient")
    }

    private fun JSONObject.optionalString(key: String): String? =
        if (isNull(key)) null else (opt(key) as? String)?.takeIf { it.isNotBlank() }

    private fun JSONObject.requiredString(key: String): String = optionalString(key) ?: throw ActionDecodeException("missing_field:$key")

    private fun JSONObject.optionalLong(key: String): Long? {
        if (isNull(key)) return null
        val number = opt(key) as? Number ?: throw ActionDecodeException("invalid_field:$key")
        val value = number.toLong()
        if (value.toDouble() != number.toDouble()) throw ActionDecodeException("invalid_field:$key")
        return value
    }

    private fun JSONObject.optionalInt(key: String): Int? =
        optionalLong(key)?.let {
            if (it !in Int.MIN_VALUE..Int.MAX_VALUE) throw ActionDecodeException("invalid_field:$key")
            it.toInt()
        }

    private fun JSONObject.requiredLong(key: String): Long = optionalLong(key) ?: throw ActionDecodeException("missing_field:$key")

    private fun JSONObject.requiredInt(key: String): Int = optionalInt(key) ?: throw ActionDecodeException("missing_field:$key")
}
