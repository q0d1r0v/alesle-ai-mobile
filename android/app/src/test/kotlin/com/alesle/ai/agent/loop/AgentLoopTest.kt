package com.alesle.ai.agent.loop

import com.alesle.ai.agent.action.ActionResult
import com.alesle.ai.agent.action.AgentAction
import com.alesle.ai.agent.action.Choice
import com.alesle.ai.agent.action.GlobalAction
import com.alesle.ai.agent.intent.IntentAction
import com.alesle.ai.agent.protocol.DecodedAction
import com.alesle.ai.agent.snapshot.Bounds
import com.alesle.ai.agent.snapshot.CapturedScreen
import com.alesle.ai.agent.snapshot.Orientation
import com.alesle.ai.agent.snapshot.ScreenSnapshot
import com.alesle.ai.agent.vision.Screenshot
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertSame
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

// org.json is a stub on the plain JVM; Robolectric provides the real one.
@RunWith(RobolectricTestRunner::class)
class AgentLoopTest {
    private val worker = QueueWorker()
    private val device = FakeDevice()
    private val ui = FakeUi()
    private val sockets = FakeSockets()
    private val events = mutableListOf<LoopEvent>()

    private fun loop(
        policy: ConfirmPolicy = ConfirmPolicy.CONFIRM,
        delays: List<Long> = listOf(100L, 200L),
    ) = AgentLoop(LoopRequest("Budilnik 7:30", "uz", policy), sockets, device, ui, worker, { events += it }, delays)

    /** Starts, opens the socket and gets the task accepted. */
    private fun accepted(policy: ConfirmPolicy = ConfirmPolicy.CONFIRM): AgentLoop {
        val loop = loop(policy)
        loop.start()
        worker.drain()
        sockets.open()
        sockets.receive("""{"type":"task.accepted","taskId":"t1"}""")
        return loop
    }

    private fun act(
        stepId: String,
        action: String,
        confirm: String? = null,
    ) =
        """{"type":"act","stepId":"$stepId","action":$action,"say":"Ishlayapman"${if (confirm == null) "" else ""","confirm":$confirm"""}}"""

    @Test
    fun `starts the task when the socket opens`() {
        accepted()
        assertEquals(
            JSONObject()
                .put("type", "task.start")
                .put("command", "Budilnik 7:30")
                .put("locale", "uz")
                .put("policy", "confirm")
                .toString(),
            sockets.sent.first(),
        )
        assertEquals(listOf(LoopEvent.Started), events)
    }

    @Test
    fun `answers observe with the current screen`() {
        accepted()
        sockets.receive("""{"type":"observe"}""")
        val observation = JSONObject(sockets.sent.last())
        assertEquals("observation", observation.getString("type"))
        assertTrue(observation.isNull("stepId"))
        assertTrue(observation.isNull("result"))
        assertEquals("com.example", observation.getJSONObject("snapshot").getString("package"))
    }

    @Test
    fun `runs an action on the last screen, settles, and reports with a fresh screen`() {
        accepted()
        sockets.receive("""{"type":"observe"}""")
        val first = device.lastCapture
        sockets.receive(act("s1", """{"type":"back"}"""))

        assertEquals(listOf(DecodedAction.Screen(AgentAction.Global(GlobalAction.BACK))), device.executed)
        assertSame(first, device.executedOn.single())
        assertEquals(1, device.settles)
        assertEquals(listOf("Ishlayapman"), ui.steps)
        assertEquals(LoopEvent.Step("Ishlayapman"), events.last())
        val observation = JSONObject(sockets.sent.last())
        assertEquals("s1", observation.getString("stepId"))
        assertEquals("ok", observation.getJSONObject("result").getString("status"))
        assertFalse(observation.isNull("snapshot"))
    }

    @Test
    fun `answers a screenshot request with the picture, taken with the overlay concealed`() {
        accepted()
        sockets.receive("""{"type":"observe","screenshot":true}""")
        val observation = JSONObject(sockets.sent.last())
        assertEquals("JPEG", observation.getString("screenshot"))
        assertTrue(observation.isNull("stepId"))
        assertFalse(observation.has("secure"))
        assertEquals(1, ui.concealments)
        assertEquals(1, device.screenshots)
    }

    @Test
    fun `reports a window that forbids capture, or no picture at all`() {
        accepted()
        device.picture = Screenshot.Secure
        sockets.receive("""{"type":"observe","screenshot":true}""")
        val secure = JSONObject(sockets.sent.last())
        assertTrue(secure.getBoolean("secure"))
        assertTrue(secure.isNull("screenshot"))

        device.picture = Screenshot.Unavailable
        sockets.receive("""{"type":"observe","screenshot":true}""")
        val none = JSONObject(sockets.sent.last())
        assertTrue(none.has("screenshot") && none.isNull("screenshot"))
        assertFalse(none.has("secure"))
    }

    @Test
    fun `a plain observe takes no picture`() {
        accepted()
        sockets.receive("""{"type":"observe"}""")
        assertFalse(JSONObject(sockets.sent.last()).has("screenshot"))
        assertEquals(0, device.screenshots)
    }

    @Test
    fun `hides the overlay while an action may touch the screen, not for keys, waits or intents`() {
        accepted()
        sockets.receive(act("s1", """{"type":"tap","nodeId":0}"""))
        assertEquals(1, ui.concealments)
        sockets.receive(act("s2", """{"type":"back"}"""))
        sockets.receive(act("s3", """{"type":"wait","ms":100}"""))
        sockets.receive(act("s4", """{"type":"intent","kind":"web_search","query":"x"}"""))
        assertEquals(1, ui.concealments)
        sockets.receive(act("s5", """{"type":"scroll","direction":"down"}"""))
        assertEquals(2, ui.concealments)
    }

    @Test
    fun `sends a null snapshot when nothing is readable`() {
        accepted()
        device.screen = null
        sockets.receive("""{"type":"observe"}""")
        assertTrue(JSONObject(sockets.sent.last()).isNull("snapshot"))
    }

    @Test
    fun `reports an action it cannot decode without running anything`() {
        accepted()
        sockets.receive(act("s1", """{"type":"teleport"}"""))
        assertTrue(device.executed.isEmpty())
        val result = JSONObject(sockets.sent.last()).getJSONObject("result")
        assertEquals("error", result.getString("status"))
        assertEquals("unknown_action:teleport", result.getString("reason"))
    }

    @Test
    fun `asks before a call the server did not mark, and refuses USSD codes`() {
        accepted()
        sockets.receive(act("s1", """{"type":"intent","kind":"call","to":{"contact":"Onam"}}"""))
        assertTrue(device.executed.isEmpty())
        assertEquals(1, ui.confirmations.size)
        ui.answerConfirm(false)
        sockets.receive(act("s2", """{"type":"intent","kind":"call","to":{"phone":"*880*1*50000#"}}"""))
        assertTrue(device.executed.isEmpty())
        assertEquals(1, ui.confirmations.size)
    }

    @Test
    fun `the call sheet names the contact the call reaches, not the words heard`() {
        device.callee = "Eval Tester ··0100"
        accepted()
        sockets.receive(act("s1", """{"type":"intent","kind":"call","to":{"contact":"Эвел Тестер"}}"""))
        assertEquals(
            "Eval Tester ··0100",
            ui.confirmations
                .single()
                .first.detail,
        )
        device.callee = null
        ui.answerConfirm(false)
        worker.drain()
        sockets.receive(act("s2", """{"type":"intent","kind":"call","to":{"contact":"Onam"}}"""))
        assertEquals(
            "Onam",
            ui.confirmations
                .last()
                .first.detail,
        )
    }

    @Test
    fun `never runs a sensitive step without a yes`() {
        accepted()
        sockets.receive(
            act(
                "s1",
                """{"type":"intent","kind":"call","to":{"contact":"Onam"}}""",
                """{"title":"Onamga qo'ng'iroq?","detail":"","always":false}""",
            ),
        )
        assertTrue(device.executed.isEmpty())
        // The sheet is built on the phone from the action, not from the server's words.
        assertEquals(Confirmation("Qo‘ng‘iroq qilinsinmi?", "Onam", false), ui.confirmations.single().first)
        assertFalse(ui.confirmations.single().second)

        ui.answerConfirm(true)
        worker.drain()
        assertEquals(
            listOf(
                DecodedAction.Intent(
                    IntentAction.Call(
                        com.alesle.ai.agent.intent.Recipient
                            .ContactName("Onam"),
                    ),
                ),
            ),
            device.executed,
        )
    }

    @Test
    fun `a no is reported as declined`() {
        accepted()
        sockets.receive(act("s1", """{"type":"tap","nodeId":0}""", """{"title":"Yuborilsinmi?","detail":"Kech qolaman","always":false}"""))
        ui.answerConfirm(false)
        worker.drain()
        assertTrue(device.executed.isEmpty())
        assertEquals("declined", JSONObject(sockets.sent.last()).getJSONObject("result").getString("status"))
    }

    @Test
    fun `countdown policy uses a countdown, except where confirmation is always required`() {
        accepted(ConfirmPolicy.COUNTDOWN)
        sockets.receive(act("s1", """{"type":"back"}""", """{"title":"t","detail":"","always":false}"""))
        assertTrue(ui.confirmations.last().second)
        ui.answerConfirm(true)
        worker.drain()

        sockets.receive(act("s2", """{"type":"back"}""", """{"title":"To'lov","detail":"10 000","always":true}"""))
        assertFalse(ui.confirmations.last().second)
    }

    @Test
    fun `a repeated step id is reported, never run twice`() {
        accepted()
        sockets.receive(act("s1", """{"type":"back"}"""))
        sockets.receive(act("s1", """{"type":"back"}"""))
        assertEquals(1, device.executed.size)
        assertEquals("s1", JSONObject(sockets.sent.last()).getString("stepId"))
        assertEquals(listOf("Ishlayapman"), ui.steps)
    }

    @Test
    fun `asks the user and sends the answer`() {
        accepted()
        sockets.receive("""{"type":"ask","askId":"a1","question":"Qaysi Aziz?","choices":[{"ref":"contact:1","label":"Aziz ··4567"}]}""")
        assertEquals("Qaysi Aziz?" to listOf(Choice("contact:1", "Aziz ··4567")), ui.asks.single().let { it.first to it.second })
        ui.answerAsk("contact:1")
        worker.drain()
        assertEquals(
            JSONObject()
                .put("type", "reply")
                .put("askId", "a1")
                .put("choice", "contact:1")
                .toString(),
            sockets.sent.last(),
        )
    }

    // ── Hands-free: speaking while the task runs ─────────────────────────────

    @Test
    fun `words said while it runs go to the server as a change to the task`() {
        val loop = accepted()
        loop.amend("  buni ham qilib ket  ")
        loop.amend("   ")
        worker.drain()
        assertEquals(JSONObject().put("type", "task.amend").put("text", "buni ham qilib ket").toString(), sockets.sent.last())
        assertEquals(1, sockets.sent.count { it.contains("task.amend") })
    }

    @Test
    fun `a spoken name answers the open question`() {
        val loop = accepted()
        sockets.receive(
            """{"type":"ask","askId":"a1","question":"Qaysi Aziz?","choices":[{"ref":"c1","label":"Aziz Karimov"},{"ref":"c2","label":"Aziz Ish"}]}""",
        )
        loop.amend("Aziz Ish")
        worker.drain()
        assertEquals(
            JSONObject()
                .put("type", "reply")
                .put("askId", "a1")
                .put("choice", "c2")
                .toString(),
            sockets.sent.last(),
        )
        assertEquals(1, ui.dismissals)
        // The sheet's own answer, arriving late, is not sent a second time.
        ui.answerAsk("c1")
        worker.drain()
        assertEquals(1, sockets.sent.count { it.contains("\"reply\"") })
    }

    @Test
    fun `other words close the question and change the task`() {
        val loop = accepted()
        sockets.receive("""{"type":"ask","askId":"a1","question":"Qaysi?","choices":[{"ref":"c1","label":"Aziz"}]}""")
        loop.amend("Onamga yoz")
        worker.drain()
        assertTrue(sockets.sent.last().contains("task.amend"))
        assertEquals(1, ui.dismissals)
    }

    @Test
    fun `yes and no answer a confirmation by voice, but a payment needs the tap`() {
        val loop = accepted()
        sockets.receive(act("s1", """{"type":"back"}""", """{"title":"Yuborilsinmi?","detail":"","always":false}"""))
        loop.amend("ha, yubor")
        worker.drain()
        assertEquals(1, device.executed.size)
        assertEquals(1, ui.dismissals)

        sockets.receive(act("s2", """{"type":"back"}""", """{"title":"Yuborilsinmi?","detail":"","always":false}"""))
        loop.amend("yo'q")
        worker.drain()
        assertEquals(1, device.executed.size)
        assertEquals("declined", JSONObject(sockets.sent.last()).getJSONObject("result").getString("status"))

        sockets.receive(act("s3", """{"type":"back"}""", """{"title":"To'lov","detail":"10 000","always":true}"""))
        val before = sockets.sent.size
        loop.amend("ha")
        worker.drain()
        assertEquals(1, device.executed.size)
        assertEquals(before, sockets.sent.size)
        ui.answerConfirm(true)
        worker.drain()
        assertEquals(2, device.executed.size)
    }

    @Test
    fun `finishes when the server says so`() {
        accepted()
        sockets.receive("""{"type":"finish","status":"done","reply":"Budilnik qo'yildi"}""")
        assertEquals(LoopEvent.Finished("done", null, "Budilnik qo'yildi"), events.last())
        assertEquals(1, ui.hides)
        assertTrue(sockets.closed)

        sockets.receive("""{"type":"observe"}""")
        assertTrue(device.captures == 0)
    }

    @Test
    fun `waits for the user without a sheet until the screen changes`() {
        accepted()
        device.hash = "dialog"
        sockets.receive("""{"type":"observe"}""")
        sockets.receive(act("s1", """{"type":"wait_for_user","timeoutMs":5000}"""))
        assertEquals(listOf("Ishlayapman"), ui.steps)
        assertTrue(ui.asks.isEmpty())
        assertTrue(device.executed.isEmpty())

        // Still the dialog: keep waiting.
        worker.runDelayed()
        assertEquals(listOf(AgentLoop.USER_POLL_MS, AgentLoop.USER_POLL_MS), worker.delays)
        // A re-sent act while waiting does not start a second wait.
        sockets.receive(act("s1", """{"type":"wait_for_user","timeoutMs":5000}"""))
        assertEquals(2, worker.delays.size)

        device.hash = null
        worker.runDelayed()
        val observation = JSONObject(sockets.sent.last())
        assertEquals("s1", observation.getString("stepId"))
        assertEquals("ok", observation.getJSONObject("result").getString("status"))
        assertTrue(device.settles > 0)
    }

    @Test
    fun `gives up waiting for the user after the timeout`() {
        accepted()
        device.hash = "lock"
        sockets.receive("""{"type":"observe"}""")
        sockets.receive(act("s1", """{"type":"wait_for_user","timeoutMs":5000}"""))
        val polls = (5_000 / AgentLoop.USER_POLL_MS).toInt()
        repeat(polls) { worker.runDelayed() }
        val result = JSONObject(sockets.sent.last()).getJSONObject("result")
        assertEquals("error", result.getString("status"))
        assertEquals(AgentLoop.USER_TIMEOUT, result.getString("reason"))
        assertEquals(polls, worker.delays.size)
    }

    @Test
    fun `STOP while waiting for the user ends the wait`() {
        val loop = accepted()
        device.hash = "dialog"
        sockets.receive(act("s1", """{"type":"wait_for_user"}"""))
        loop.stop()
        val sent = sockets.sent.size
        worker.runDelayed()
        assertEquals(sent, sockets.sent.size)
    }

    @Test
    fun `STOP ends at once and tells the server`() {
        val loop = accepted()
        loop.stop()
        assertEquals(LoopEvent.Finished("stopped", "user_stopped", null), events.last())
        assertEquals("""{"type":"task.stop"}""", sockets.sent.last())
        assertTrue(sockets.closed)

        loop.stop()
        assertEquals(1, events.count { it is LoopEvent.Finished })
    }

    @Test
    fun `STOP during a confirmation drops the answer`() {
        val loop = accepted()
        sockets.receive(act("s1", """{"type":"back"}""", """{"title":"t","detail":"","always":false}"""))
        loop.stop()
        ui.answerConfirm(true)
        worker.drain()
        assertTrue(device.executed.isEmpty())
    }

    @Test
    fun `reconnects and resumes the task after a drop`() {
        accepted()
        sockets.gone()
        assertEquals(listOf(100L), worker.delays)
        worker.runDelayed()
        sockets.open()
        assertEquals("""{"type":"task.resume","taskId":"t1"}""", sockets.sent.last())
        assertEquals(2, sockets.connects)
        // A resumed task does not count as started again.
        sockets.receive("""{"type":"task.accepted","taskId":"t1"}""")
        assertEquals(1, events.count { it == LoopEvent.Started })
    }

    @Test
    fun `gives up after the reconnect budget`() {
        accepted()
        sockets.gone()
        worker.runDelayed()
        sockets.gone()
        worker.runDelayed()
        sockets.gone()
        assertEquals(LoopEvent.Finished("interrupted", "connection_lost", null), events.last())
    }

    @Test
    fun `fails fast when the server cannot be reached at all`() {
        loop().start()
        worker.drain()
        sockets.gone()
        assertEquals(LoopEvent.Finished("failed", "server_unreachable", null), events.single())
    }

    @Test
    fun `an outdated app ends at once instead of reconnecting`() {
        accepted()
        sockets.upgradeRequired()
        sockets.upgradeRequired()
        assertEquals(LoopEvent.Finished("failed", "upgrade_required", null), events.single { it is LoopEvent.Finished })
        assertTrue(worker.delays.isEmpty())
    }

    @Test
    fun `ends on server errors that make the task impossible`() {
        accepted()
        sockets.receive("""{"type":"error","code":"bad_frame"}""")
        assertNull(events.filterIsInstance<LoopEvent.Finished>().firstOrNull())
        sockets.receive("""{"type":"error","code":"already_running"}""")
        assertEquals(LoopEvent.Finished("failed", "already_running", null), events.last())

        events.clear()
        val other = FakeSockets()
        val loop2 = AgentLoop(LoopRequest("x", "uz", ConfirmPolicy.CONFIRM), other, device, ui, worker, { events += it })
        loop2.start()
        worker.drain()
        other.open()
        other.receive("""{"type":"task.accepted","taskId":"t9"}""")
        other.receive("""{"type":"error","code":"unknown_task"}""")
        assertEquals(LoopEvent.Finished("interrupted", "connection_lost", null), events.last())
    }

    @Test
    fun `ignores frames it does not understand`() {
        accepted()
        val before = sockets.sent.size
        sockets.receive("not json")
        sockets.receive("""{"type":"act"}""")
        sockets.receive("""{"type":"nope"}""")
        assertEquals(before, sockets.sent.size)
    }

    @Test
    fun `a stop that lands mid-action skips settling and reporting`() {
        lateinit var loop: AgentLoop
        device.onExecute = { loop.stop() }
        loop = accepted()
        sockets.receive(act("s1", """{"type":"back"}"""))
        assertEquals(0, device.settles)
        assertEquals("""{"type":"task.stop"}""", sockets.sent.last())
    }

    // ── Fakes ───────────────────────────────────────────────────────────────

    private inner class FakeSockets : LoopSocketFactory {
        val sent = mutableListOf<String>()
        var closed = false
        var connects = 0
        private var listener: LoopSocketListener? = null

        override fun connect(listener: LoopSocketListener): LoopSocket {
            connects++
            this.listener = listener
            closed = false
            return object : LoopSocket {
                override fun send(text: String): Boolean {
                    sent += text
                    return true
                }

                override fun close() {
                    closed = true
                }
            }
        }

        fun open() {
            listener!!.onOpen()
            worker.drain()
        }

        fun receive(text: String) {
            listener!!.onMessage(text)
            worker.drain()
        }

        fun gone() {
            listener!!.onGone()
            worker.drain()
        }

        fun upgradeRequired() {
            listener!!.onUpgradeRequired()
            worker.drain()
        }
    }
}

private class QueueWorker : LoopWorker {
    private val queue = ArrayDeque<() -> Unit>()
    private val delayed = ArrayDeque<() -> Unit>()
    val delays = mutableListOf<Long>()

    override fun post(task: () -> Unit) {
        queue.addLast(task)
    }

    override fun postDelayed(
        delayMs: Long,
        task: () -> Unit,
    ) {
        delays += delayMs
        delayed.addLast(task)
    }

    fun drain() {
        while (queue.isNotEmpty()) queue.removeFirst()()
    }

    fun runDelayed() {
        delayed.removeFirst()()
        drain()
    }
}

private class FakeDevice : LoopDevice {
    var callee: String? = null

    override fun recipientLabel(action: DecodedAction): String? = callee

    var screen: CapturedScreen? = screen()
    var lastCapture: CapturedScreen? = null
    var captures = 0
    var settles = 0
    var onExecute: () -> Unit = {}
    val executed = mutableListOf<DecodedAction>()
    val executedOn = mutableListOf<CapturedScreen?>()

    /** When set, every capture shows this same screen. */
    var hash: String? = null

    override fun capture(): CapturedScreen? {
        captures++
        lastCapture = screen?.let { screen(captures, hash) }
        return lastCapture
    }

    override fun execute(
        action: DecodedAction,
        screen: CapturedScreen?,
    ): ActionResult {
        executed += action
        executedOn += screen
        onExecute()
        return ActionResult.OK
    }

    override fun settle() {
        settles++
    }

    var picture: Screenshot = Screenshot.Image("JPEG")
    var screenshots = 0

    override fun screenshot(): Screenshot {
        screenshots++
        return picture
    }

    private fun screen(
        n: Int = 0,
        hash: String? = null,
    ) = CapturedScreen(
        ScreenSnapshot(
            "s-$n",
            "com.example",
            null,
            hash ?: "hash-$n",
            "uz",
            Orientation.PORTRAIT,
            emptyList(),
            keyboardVisible = false,
            truncated = false,
        ),
        emptyList(),
        Bounds(0, 0, 1080, 2400),
    )
}

private class FakeUi : LoopUi {
    val steps = mutableListOf<String>()
    val confirmations = mutableListOf<Pair<Confirmation, Boolean>>()
    val asks = mutableListOf<Triple<String, List<Choice>, (String?) -> Unit>>()
    var hides = 0
    private var confirmAnswer: ((Boolean) -> Unit)? = null

    override fun showStep(say: String) {
        steps += say
    }

    override fun confirm(
        confirmation: Confirmation,
        countdown: Boolean,
        answer: (approved: Boolean) -> Unit,
    ) {
        confirmations += confirmation to countdown
        confirmAnswer = answer
    }

    override fun ask(
        question: String,
        choices: List<Choice>,
        answer: (ref: String?) -> Unit,
    ) {
        asks += Triple(question, choices, answer)
    }

    override fun hide() {
        hides++
    }

    var dismissals = 0

    override fun dismissSheet() {
        dismissals++
    }

    var concealments = 0

    override fun <T> concealed(capture: () -> T): T {
        concealments++
        return capture()
    }

    fun answerConfirm(approved: Boolean) = confirmAnswer!!(approved)

    fun answerAsk(ref: String?) = asks.last().third(ref)
}
