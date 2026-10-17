package com.alesle.ai.listen

import com.alesle.ai.agent.generated.LiveEvent
import com.alesle.ai.agent.generated.LiveEventKind
import com.alesle.ai.agent.generated.LivePhase
import com.alesle.ai.agent.loop.LoopSocket
import com.alesle.ai.agent.loop.LoopSocketListener
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.util.Base64

@RunWith(RobolectricTestRunner::class)
class LiveSessionTest {
    private class FakeSocket(
        val token: String,
        val listener: LoopSocketListener,
    ) : LoopSocket {
        val sent = mutableListOf<JSONObject>()
        var closed = false

        override fun send(text: String): Boolean {
            sent += JSONObject(text)
            return true
        }

        override fun close() {
            closed = true
        }

        fun types() = sent.map { it.getString("type") }

        fun server(frame: String) = listener.onMessage(frame)
    }

    private class FakeSink : VoiceSink {
        val played = mutableListOf<ByteArray>()
        var stops = 0
        override var playing = false
        override var onDrained: (() -> Unit)? = null

        override fun play(pcm: ByteArray) {
            played += pcm
            playing = true
        }

        override fun stop() {
            stops++
            playing = false
        }

        override fun release() = Unit

        fun drain() {
            playing = false
            onDrained?.invoke()
        }
    }

    private val sockets = mutableListOf<FakeSocket>()
    private val sink = FakeSink()
    private val events = mutableListOf<LiveEvent>()
    private val scheduled = mutableListOf<Pair<Long, () -> Unit>>()

    private val session =
        LiveSession(
            socketsFor = { token ->
                com.alesle.ai.agent.loop.LoopSocketFactory { listener ->
                    FakeSocket(token, listener).also {
                        sockets +=
                            it
                    }
                }
            },
            token = "t1",
            locale = "uz",
            sink = sink,
            events = { events += it },
            schedule = { delay, block -> scheduled += delay to block },
        )

    private val socket get() = sockets.last()

    private fun phases() = events.filter { it.kind == LiveEventKind.PHASE }.map { it.phase }

    private fun frame(n: Int) = ShortArray(VoiceActivityDetector.FRAME_SAMPLES) { n.toShort() }

    private fun ready(): FakeSocket {
        session.start()
        socket.listener.onOpen()
        socket.server("""{"type":"live.ready"}""")
        return socket
    }

    @Test
    fun `opens with the token, starts in the app's language and is ready to listen`() {
        val s = ready()
        assertEquals("t1", s.token)
        assertEquals(JSONObject().put("type", "live.start").put("locale", "uz").toString(), s.sent.single().toString())
        assertEquals(listOf(LivePhase.CONNECTING, LivePhase.LISTENING), phases())
        assertTrue(session.handlesSpeech)
    }

    @Test
    fun `speech goes up in 100 ms chunks between start and end, and the voice comes back`() {
        val s = ready()
        session.onSpeechStart(List(3) { frame(it) })
        repeat(4) { session.onSpeechFrame(frame(9)) }
        session.onSpeechEnd(cancelled = false)
        assertEquals(listOf("live.start", "speech.start", "audio", "audio", "speech.end"), s.types())
        val first = Base64.getDecoder().decode(s.sent[2].getString("data"))
        assertEquals(5 * VoiceActivityDetector.FRAME_SAMPLES * 2, first.size)
        assertEquals(LivePhase.THINKING, phases().last())

        s.server("""{"type":"audio","data":"AAEC"}""")
        assertEquals(listOf(0, 1, 2), sink.played.single().map { it.toInt() })
        assertEquals(LivePhase.SPEAKING, phases().last())
        s.server("""{"type":"caption","role":"assistant","text":"Salom!","final":true}""")
        assertEquals(LiveEvent(kind = LiveEventKind.CAPTION, role = "assistant", text = "Salom!", isFinal = true), events.last())
        // Listening again only once the voice has played out.
        s.server("""{"type":"turn.done"}""")
        assertEquals(LivePhase.SPEAKING, phases().last())
        sink.drain()
        assertEquals(LivePhase.LISTENING, phases().last())
    }

    @Test
    fun `speaking over Alesle stops its voice at once, and its late words are not played`() {
        val s = ready()
        s.server("""{"type":"audio","data":"AAEC"}""")
        assertTrue(session.strict)
        session.onSpeechStart(listOf(frame(1)))
        assertEquals(1, sink.stops)
        assertFalse(session.strict)
        s.server("""{"type":"audio","data":"AwQF"}""")
        assertEquals(1, sink.played.size)
        s.server("""{"type":"interrupted"}""")
        assertEquals(2, sink.stops)
        assertEquals(LivePhase.HEARING, phases().last())
    }

    @Test
    fun `nothing is sent before the server is ready, or after the speech it did not see start`() {
        session.start()
        session.onSpeechStart(listOf(frame(1)))
        session.onSpeechFrame(frame(2))
        session.onSpeechEnd(cancelled = false)
        assertTrue(socket.sent.isEmpty())
    }

    @Test
    fun `phone work, changes and stops go to the app, and the result goes back`() {
        val s = ready()
        s.server("""{"type":"task.run","callId":"c1","command":"Soatni och"}""")
        s.server("""{"type":"task.amend","text":"sekundomerni ham"}""")
        s.server("""{"type":"task.stop"}""")
        s.server("""{"type":"task.run","callId":"","command":"x"}""")
        assertEquals(
            listOf(
                LiveEvent(kind = LiveEventKind.TASK_RUN, callId = "c1", text = "Soatni och"),
                LiveEvent(kind = LiveEventKind.TASK_AMEND, text = "sekundomerni ham"),
                LiveEvent(kind = LiveEventKind.TASK_STOP),
            ),
            events.filter { it.kind != LiveEventKind.PHASE },
        )
        session.taskResult("c1", "done", "Soat ochildi")
        assertEquals(
            JSONObject()
                .put("type", "task.result")
                .put("callId", "c1")
                .put("status", "done")
                .put("reply", "Soat ochildi")
                .toString(),
            s.sent.last().toString(),
        )
        session.sendText("Salom")
        assertEquals("text", s.sent.last().getString("type"))
    }

    @Test
    fun `a lost connection is retried with growing pauses, then hands-free falls back and tries Live later`() {
        ready().listener.onGone()
        assertEquals(LivePhase.CONNECTING, phases().last())
        assertEquals(listOf(1_000L), scheduled.map { it.first })
        scheduled.removeAt(0).second()
        socket.listener.onGone()
        scheduled.removeAt(0).second()
        socket.listener.onGone()
        scheduled.removeAt(0).second()
        assertEquals(4, sockets.size)
        socket.listener.onGone()
        assertEquals(LivePhase.FALLBACK, phases().last())
        assertFalse(session.handlesSpeech)
        assertEquals(LiveSession.RETRY_AFTER_FALLBACK_MS, scheduled.single().first)
        scheduled.removeAt(0).second()
        assertEquals(5, sockets.size)
        assertTrue(session.handlesSpeech)
    }

    @Test
    fun `the server saying Live is unavailable falls back at once, and a used-up plan ends it`() {
        val s = ready()
        s.server("""{"type":"error","code":"unavailable"}""")
        assertTrue(s.closed)
        assertEquals(LivePhase.FALLBACK, phases().last())
        scheduled.removeAt(0).second()
        socket.listener.onOpen()
        socket.server("""{"type":"live.ready"}""")
        socket.server("""{"type":"error","code":"limit_reached"}""")
        assertEquals(LivePhase.LIMIT_REACHED, phases().last())
        assertFalse(session.handlesSpeech)
        assertTrue(socket.closed)
    }

    @Test
    fun `a refused token waits for a fresh one`() {
        session.start()
        socket.listener.onUnauthorized()
        assertEquals(LivePhase.UNAUTHORIZED, phases().last())
        assertTrue(scheduled.isEmpty())
        session.updateToken("t2")
        assertEquals("t2", socket.token)
        assertEquals(2, sockets.size)
    }

    @Test
    fun `stopping closes the connection and ignores whatever comes after`() {
        val s = ready()
        session.stop()
        assertTrue(s.closed)
        s.server("""{"type":"audio","data":"AAEC"}""")
        s.listener.onGone()
        assertTrue(sink.played.isEmpty())
        assertTrue(scheduled.isEmpty())
        assertFalse(session.handlesSpeech)
    }

    @Test
    fun `junk from the server is ignored`() {
        val s = ready()
        val before = events.size
        s.server("not json")
        s.server("""{"type":"audio","data":"%%%"}""")
        s.server("""{"type":"caption","role":"system","text":"x"}""")
        s.server("""{"type":"error","code":"bad_frame"}""")
        assertEquals(before, events.size)
        assertTrue(session.handlesSpeech)
    }
}
