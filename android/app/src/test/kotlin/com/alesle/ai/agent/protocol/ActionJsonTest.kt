package com.alesle.ai.agent.protocol

import com.alesle.ai.agent.action.ActionExecutor
import com.alesle.ai.agent.action.ActionResult
import com.alesle.ai.agent.action.AgentAction
import com.alesle.ai.agent.action.Choice
import com.alesle.ai.agent.action.GlobalAction
import com.alesle.ai.agent.action.NodeMatcher
import com.alesle.ai.agent.action.Target
import com.alesle.ai.agent.intent.IntentAction
import com.alesle.ai.agent.intent.Recipient
import com.alesle.ai.agent.snapshot.ScrollDirection
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

// org.json is an Android stub on the plain JVM; Robolectric provides the real one.
@RunWith(RobolectricTestRunner::class)
class ActionJsonTest {
    private fun screen(json: String) = (ActionJson.decode(json) as DecodedAction.Screen).action

    private fun intent(json: String) = (ActionJson.decode(json) as DecodedAction.Intent).action

    private fun failure(json: String): String =
        try {
            ActionJson.decode(json)
            error("expected a decode failure for $json")
        } catch (e: ActionDecodeException) {
            e.reason
        }

    @Test
    fun `decodes taps and long presses on nodes and points`() {
        assertEquals(AgentAction.Tap(Target.Node(4)), screen("""{"type":"tap","nodeId":4}"""))
        assertEquals(AgentAction.Tap(Target.Point(0.5, 0.8)), screen("""{"type":"tap","point":[0.5,0.8]}"""))
        assertEquals(AgentAction.LongPress(Target.Node(0)), screen("""{"type":"long_press","nodeId":0}"""))
        assertEquals(AgentAction.LongPress(Target.Point(1.0, 0.0)), screen("""{"type":"long_press","point":[1,0]}"""))
    }

    @Test
    fun `decodes typing, scrolling and global actions`() {
        assertEquals(
            AgentAction.TypeText(2, "salom", submit = true),
            screen("""{"type":"type_text","nodeId":2,"text":"salom","submit":true}"""),
        )
        assertEquals(AgentAction.TypeText(2, "salom"), screen("""{"type":"type_text","nodeId":2,"text":"salom"}"""))
        assertEquals(AgentAction.Scroll(ScrollDirection.DOWN), screen("""{"type":"scroll","direction":"down"}"""))
        assertEquals(AgentAction.Scroll(ScrollDirection.LEFT, 7), screen("""{"type":"scroll","direction":"LEFT","nodeId":7}"""))
        assertEquals(AgentAction.Global(GlobalAction.BACK), screen("""{"type":"back"}"""))
        assertEquals(AgentAction.Global(GlobalAction.HOME), screen("""{"type":"home"}"""))
        assertEquals(AgentAction.Global(GlobalAction.RECENTS), screen("""{"type":"recents"}"""))
    }

    @Test
    fun `decodes waits with and without a matcher`() {
        assertEquals(AgentAction.Wait(ActionExecutor.MAX_WAIT_MS), screen("""{"type":"wait"}"""))
        assertEquals(
            AgentAction.Wait(1500, NodeMatcher(textContains = "Yuborildi", viewId = "status")),
            screen("""{"type":"wait","ms":1500,"until":{"textContains":"Yuborildi","viewId":"status"}}"""),
        )
    }

    @Test
    fun `decodes a wait for the user, its timeout kept within bounds`() {
        assertEquals(DecodedAction.WaitForUser(60_000), ActionJson.decode("""{"type":"wait_for_user"}"""))
        assertEquals(DecodedAction.WaitForUser(30_000), ActionJson.decode("""{"type":"wait_for_user","timeoutMs":30000}"""))
        assertEquals(DecodedAction.WaitForUser(5_000), ActionJson.decode("""{"type":"wait_for_user","timeoutMs":10}"""))
        assertEquals(DecodedAction.WaitForUser(120_000), ActionJson.decode("""{"type":"wait_for_user","timeoutMs":9999999}"""))
    }

    @Test
    fun `decodes app launches`() {
        assertEquals(
            IntentAction.LaunchApp(packageName = "org.telegram.messenger"),
            intent("""{"type":"launch_app","package":"org.telegram.messenger"}"""),
        )
        assertEquals(IntentAction.LaunchApp(appName = "Uzum Market"), intent("""{"type":"launch_app","name":"Uzum Market"}"""))
        assertEquals("app_not_specified", failure("""{"type":"launch_app","name":"  "}"""))
    }

    @Test
    fun `decodes calls and SMS to each kind of recipient`() {
        assertEquals(
            IntentAction.Call(Recipient.Phone("+998901234567")),
            intent("""{"type":"intent","kind":"call","to":{"phone":"+998901234567"}}"""),
        )
        assertEquals(
            IntentAction.Call(Recipient.ContactName("Aziz")),
            intent("""{"type":"intent","kind":"call","to":{"contact":"Aziz"}}"""),
        )
        assertEquals(
            IntentAction.Call(Recipient.ContactRef("contact:12")),
            intent("""{"type":"intent","kind":"call","to":{"ref":"contact:12"}}"""),
        )
        assertEquals(
            IntentAction.Sms(Recipient.ContactName("Onam"), "Kech qolaman"),
            intent("""{"type":"intent","kind":"sms","to":{"contact":"Onam"},"text":"Kech qolaman"}"""),
        )
        assertEquals("missing_field:to", failure("""{"type":"intent","kind":"call"}"""))
        assertEquals("invalid_recipient", failure("""{"type":"intent","kind":"call","to":{"email":"a@b.c"}}"""))
    }

    @Test
    fun `decodes alarms, calendar events, searches and shares`() {
        assertEquals(
            IntentAction.Alarm(7, 30, "Ish", listOf(2, 3)),
            intent("""{"type":"intent","kind":"alarm","hour":7,"minute":30,"label":"Ish","days":[2,3]}"""),
        )
        assertEquals(IntentAction.Alarm(6, 0), intent("""{"type":"intent","kind":"alarm","hour":6,"minute":0}"""))
        assertEquals(
            IntentAction.CalendarEvent("Uchrashuv", 1_760_000_000_000, 1_760_003_600_000, "Chorsu"),
            intent(
                """{"type":"intent","kind":"calendar_event","title":"Uchrashuv","begin":1760000000000,"end":1760003600000,"location":"Chorsu"}""",
            ),
        )
        assertEquals(IntentAction.WebSearch("ob-havo"), intent("""{"type":"intent","kind":"web_search","query":"ob-havo"}"""))
        assertEquals(IntentAction.MapsSearch("dorixona"), intent("""{"type":"intent","kind":"maps_search","query":"dorixona"}"""))
        assertEquals(IntentAction.YouTubeSearch("Shoxrux"), intent("""{"type":"intent","kind":"youtube_search","query":"Shoxrux"}"""))
        assertEquals(IntentAction.ShareText("Salom"), intent("""{"type":"intent","kind":"share_text","text":"Salom"}"""))
        assertEquals(
            IntentAction.ShareText("Salom", "org.telegram.messenger"),
            intent("""{"type":"intent","kind":"share_text","text":"Salom","package":"org.telegram.messenger"}"""),
        )
    }

    @Test
    fun `rejects malformed actions with a reason code`() {
        assertEquals("invalid_json", failure("not json"))
        assertEquals("missing_field:type", failure("""{"nodeId":1}"""))
        assertEquals("unknown_action:jump", failure("""{"type":"jump"}"""))
        assertEquals("unknown_intent:fax", failure("""{"type":"intent","kind":"fax"}"""))
        assertEquals("target_missing", failure("""{"type":"tap"}"""))
        assertEquals("invalid_point", failure("""{"type":"tap","point":[0.5]}"""))
        assertEquals("invalid_point", failure("""{"type":"tap","point":["a","b"]}"""))
        assertEquals("invalid_field:nodeId", failure("""{"type":"tap","nodeId":1.5}"""))
        assertEquals("invalid_field:nodeId", failure("""{"type":"tap","nodeId":"4"}"""))
        assertEquals("invalid_field:nodeId", failure("""{"type":"tap","nodeId":99999999999}"""))
        assertEquals("missing_field:text", failure("""{"type":"type_text","nodeId":1}"""))
        assertEquals("invalid_direction", failure("""{"type":"scroll","direction":"sideways"}"""))
        assertEquals("missing_field:hour", failure("""{"type":"intent","kind":"alarm","minute":0}"""))
    }

    @Test
    fun `treats null fields as absent`() {
        assertEquals(AgentAction.Scroll(ScrollDirection.UP), screen("""{"type":"scroll","direction":"up","nodeId":null}"""))
        assertEquals(IntentAction.LaunchApp(appName = "Click"), intent("""{"type":"launch_app","package":null,"name":"Click"}"""))
    }

    @Test
    fun `encodes results with reason and choices only when present`() {
        assertEquals("""{"status":"ok"}""", ActionJson.encode(ActionResult.OK).toString())
        assertEquals(
            """{"status":"blocked","reason":"password_field"}""",
            ActionJson.encode(ActionResult.blocked("password_field")).toString(),
        )
        val ambiguous = ActionJson.encode(ActionResult.ambiguous("several_contacts", listOf(Choice("contact:1", "Aziz ··4567"))))
        assertEquals("ambiguous", ambiguous.getString("status"))
        assertEquals("contact:1", ambiguous.getJSONArray("choices").getJSONObject(0).getString("ref"))
        assertEquals("Aziz ··4567", ambiguous.getJSONArray("choices").getJSONObject(0).getString("label"))
        assertFalse(ActionJson.encode(ActionResult.OK).has("choices"))
    }
}
