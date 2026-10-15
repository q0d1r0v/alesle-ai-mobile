package com.alesle.ai.agent.loop

import com.alesle.ai.agent.action.ActionResult
import com.alesle.ai.agent.action.Choice
import com.alesle.ai.agent.vision.Screenshot
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class LoopFramesTest {
    @Test
    fun `decodes every server frame`() {
        assertEquals(ServerFrame.Accepted("t1"), LoopFrames.decode("""{"type":"task.accepted","taskId":"t1"}"""))
        assertEquals(ServerFrame.Observe(false), LoopFrames.decode("""{"type":"observe"}"""))
        assertEquals(ServerFrame.Observe(true), LoopFrames.decode("""{"type":"observe","screenshot":true}"""))
        val act =
            LoopFrames.decode(
                """{"type":"act","stepId":"s1","action":{"type":"back"},"say":"Orqaga","confirm":{"title":"T","detail":"D","always":true}}""",
            ) as ServerFrame.Act
        assertEquals("s1", act.stepId)
        assertEquals("back", act.action.getString("type"))
        assertEquals("Orqaga", act.say)
        assertEquals(Confirmation("T", "D", true), act.confirm)
        assertEquals(
            ServerFrame.Ask("a1", "Qaysi?", listOf(Choice("c1", "Aziz"))),
            LoopFrames.decode(
                """{"type":"ask","askId":"a1","question":"Qaysi?","choices":[{"ref":"c1","label":"Aziz"},{"label":"no ref"},5]}""",
            ),
        )
        assertEquals(
            ServerFrame.Finish("failed", "stuck", null),
            LoopFrames.decode("""{"type":"finish","status":"failed","reason":"stuck","reply":null}"""),
        )
        assertEquals(ServerFrame.Error("bad_frame"), LoopFrames.decode("""{"type":"error","code":"bad_frame"}"""))
        assertEquals(ServerFrame.Error("unknown"), LoopFrames.decode("""{"type":"error"}"""))
    }

    @Test
    fun `fills optional parts with safe defaults`() {
        val act = LoopFrames.decode("""{"type":"act","stepId":"s1","action":{"type":"home"}}""") as ServerFrame.Act
        assertEquals("", act.say)
        assertNull(act.confirm)
        val bare = LoopFrames.decode("""{"type":"act","stepId":"s1","action":{"type":"home"},"confirm":{}}""") as ServerFrame.Act
        assertEquals(Confirmation("", "", false), bare.confirm)
    }

    @Test
    fun `rejects malformed frames`() {
        listOf(
            "not json",
            """{"type":"task.accepted"}""",
            """{"type":"act","action":{"type":"back"}}""",
            """{"type":"act","stepId":"s1"}""",
            """{"type":"ask","askId":"a1","choices":[]}""",
            """{"type":"ask","choices":[{"ref":"c","label":"l"}]}""",
            """{"type":"finish"}""",
            """{"type":"whatever"}""",
            """{}""",
        ).forEach { assertNull(it, LoopFrames.decode(it)) }
    }

    @Test
    fun `encodes the phone's frames`() {
        assertEquals(
            """{"type":"task.start","command":"salom","locale":"uz","policy":"countdown"}""",
            LoopFrames.start("salom", "uz", ConfirmPolicy.COUNTDOWN),
        )
        assertEquals("""{"type":"task.resume","taskId":"t1"}""", LoopFrames.resume("t1"))
        assertEquals("""{"type":"task.stop"}""", LoopFrames.stop())
        assertEquals("""{"type":"reply","askId":"a1","choice":null}""", LoopFrames.reply("a1", null))

        val first = JSONObject(LoopFrames.observation(null, null, null))
        assertTrue(first.isNull("stepId") && first.isNull("result") && first.isNull("snapshot"))
        val later = JSONObject(LoopFrames.observation("s2", ActionResult.notFound("node_gone"), JSONObject().put("package", "p")))
        assertEquals("s2", later.getString("stepId"))
        assertEquals("node_gone", later.getJSONObject("result").getString("reason"))
        assertEquals("p", later.getJSONObject("snapshot").getString("package"))
        assertFalse(later.has("screenshot") || later.has("secure"))
    }

    @Test
    fun `encodes the answer to a screenshot request`() {
        val image = JSONObject(LoopFrames.lookObservation(null, Screenshot.Image("QUJD")))
        assertEquals("QUJD", image.getString("screenshot"))
        assertTrue(image.isNull("stepId") && image.isNull("snapshot"))
        val secure = JSONObject(LoopFrames.lookObservation(JSONObject(), Screenshot.Secure))
        assertTrue(secure.getBoolean("secure") && secure.isNull("screenshot"))
        val none = JSONObject(LoopFrames.lookObservation(null, Screenshot.Unavailable))
        assertTrue(none.isNull("screenshot") && !none.has("secure"))
    }
}
