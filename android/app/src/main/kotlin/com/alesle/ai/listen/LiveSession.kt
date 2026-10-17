package com.alesle.ai.listen

import com.alesle.ai.agent.generated.LiveEvent
import com.alesle.ai.agent.generated.LiveEventKind
import com.alesle.ai.agent.generated.LivePhase
import com.alesle.ai.agent.loop.LoopSocket
import com.alesle.ai.agent.loop.LoopSocketFactory
import com.alesle.ai.agent.loop.LoopSocketListener
import org.json.JSONException
import org.json.JSONObject
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.Base64

/**
 * One live conversation over `/v1/voice/live` (alesle-ai-api
 * docs/live-protocol.md): the detector's speech goes up as it is heard —
 * never the noise between — and the model's voice comes back and plays as
 * it streams. Speaking over Alesle stops it at once (barge-in). Phone work
 * the model asks for goes to the app as events; the app reports how it ended.
 *
 * When Live cannot be had (the server says unavailable, or the connection
 * keeps failing) the session gives up: [handlesSpeech] turns false and
 * hands-free goes back to whole utterances, then Live is tried again later.
 *
 * Callbacks come from the microphone thread, OkHttp's threads and the
 * player's; every entry point is synchronized.
 */
class LiveSession(
    private val socketsFor: (token: String) -> LoopSocketFactory,
    private var token: String,
    private val locale: String,
    private val sink: VoiceSink,
    private val events: (LiveEvent) -> Unit,
    /** Runs a callback after a delay (reconnects, the retry after a fallback). */
    private val schedule: (delayMs: Long, block: () -> Unit) -> Unit,
) : VoiceActivityDetector.SpeechStream {
    private var socket: LoopSocket? = null

    /** Which connection callbacks belong to: older ones are ignored. */
    private var connection = 0
    private var ready = false
    private var stopped = false
    private var failed = false
    private var attempts = 0
    private var hearing = false

    /** The model finished its turn but its voice is still playing. */
    private var turnDone = false
    private var phase: LivePhase? = null
    private val batch = ArrayList<ShortArray>()

    /** Counts turns, so a watchdog for an old one does nothing. */
    private var turn = 0

    init {
        sink.onDrained = ::onDrained
    }

    /** True while speech should come here rather than as whole utterances. */
    val handlesSpeech: Boolean
        @Synchronized get() = !stopped && !failed

    /** Alesle is speaking: the detector asks for louder, closer speech. */
    val strict: Boolean get() = sink.playing

    @Synchronized
    fun start() {
        if (stopped) return
        connect()
    }

    @Synchronized
    fun stop() {
        if (stopped) return
        stopped = true
        connection++
        socket?.close()
        socket = null
        sink.stop()
        sink.onDrained = null
    }

    /** A fresh token after [LivePhase.UNAUTHORIZED]. */
    @Synchronized
    fun updateToken(fresh: String) {
        token = fresh
        if (stopped || ready) return
        failed = false
        attempts = 0
        connect()
    }

    /** Typed instead of spoken. */
    @Synchronized
    fun sendText(text: String) {
        val trimmed = text.trim()
        if (!ready || trimmed.isEmpty()) return
        sink.stop()
        send(JSONObject().put("type", "text").put("text", trimmed))
        awaitAnswer()
    }

    @Synchronized
    fun taskResult(
        callId: String,
        status: String,
        reply: String?,
    ) {
        if (!ready) return
        val frame = JSONObject().put("type", "task.result").put("callId", callId).put("status", status)
        if (!reply.isNullOrBlank()) frame.put("reply", reply.take(MAX_REPLY))
        send(frame)
    }

    // ── Speech from the detector ────────────────────────────────────────────

    @Synchronized
    override fun onSpeechStart(frames: List<ShortArray>) {
        if (!ready || !handlesSpeech) return
        // Barge-in: the user's voice wins.
        if (sink.playing) sink.stop()
        turnDone = false
        hearing = true
        batch.clear()
        send(JSONObject().put("type", "speech.start"))
        frames.forEach(::add)
        setPhase(LivePhase.HEARING)
    }

    @Synchronized
    override fun onSpeechFrame(frame: ShortArray) {
        if (hearing) add(frame)
    }

    @Synchronized
    override fun onSpeechEnd(cancelled: Boolean) {
        if (!hearing) return
        hearing = false
        flush()
        send(JSONObject().put("type", "speech.end"))
        awaitAnswer()
    }

    /** Thinking, but not forever: with no answer the user is listened to again. */
    private fun awaitAnswer() {
        setPhase(LivePhase.THINKING)
        val id = ++turn
        val at = connection
        schedule(ANSWER_TIMEOUT_MS) {
            whenCurrent(at) { if (id == turn && phase == LivePhase.THINKING) setPhase(LivePhase.LISTENING) }
        }
    }

    private fun add(frame: ShortArray) {
        batch += frame
        if (batch.size >= FRAMES_PER_CHUNK) flush()
    }

    private fun flush() {
        if (batch.isEmpty()) return
        val bytes = ByteBuffer.allocate(batch.sumOf { it.size } * 2).order(ByteOrder.LITTLE_ENDIAN)
        batch.forEach { frame -> frame.forEach { bytes.putShort(it) } }
        batch.clear()
        send(JSONObject().put("type", "audio").put("data", Base64.getEncoder().encodeToString(bytes.array())))
    }

    // ── The connection ──────────────────────────────────────────────────────

    private fun connect() {
        val id = ++connection
        ready = false
        socket?.close()
        setPhase(LivePhase.CONNECTING)
        socket =
            socketsFor(token).connect(
                object : LoopSocketListener {
                    override fun onOpen() = whenCurrent(id) { send(JSONObject().put("type", "live.start").put("locale", locale)) }

                    override fun onMessage(text: String) = whenCurrent(id) { onFrame(text) }

                    override fun onGone() = whenCurrent(id) { onLost() }

                    override fun onUpgradeRequired() = whenCurrent(id) { fallBack() }

                    override fun onUnauthorized() =
                        whenCurrent(id) {
                            ready = false
                            socket = null
                            setPhase(LivePhase.UNAUTHORIZED)
                        }
                },
            )
    }

    private fun whenCurrent(
        id: Int,
        block: () -> Unit,
    ) {
        synchronized(this) {
            if (id == connection && !stopped) block()
        }
    }

    private fun onLost() {
        ready = false
        hearing = false
        socket = null
        sink.stop()
        if (failed) return
        if (attempts >= MAX_ATTEMPTS) {
            fallBack()
            return
        }
        val delay = RETRY_MS shl attempts
        attempts++
        setPhase(LivePhase.CONNECTING)
        val id = connection
        schedule(delay) { whenCurrent(id) { if (!ready && !failed) connect() } }
    }

    /** Live is not to be had now: whole utterances again, and another try later. */
    private fun fallBack() {
        failed = true
        ready = false
        hearing = false
        connection++
        socket?.close()
        socket = null
        sink.stop()
        setPhase(LivePhase.FALLBACK)
        val id = connection
        schedule(RETRY_AFTER_FALLBACK_MS) {
            whenCurrent(id) {
                failed = false
                attempts = 0
                connect()
            }
        }
    }

    private fun onFrame(text: String) {
        val frame =
            try {
                JSONObject(text)
            } catch (e: JSONException) {
                return
            }
        when (frame.optString("type")) {
            "live.ready" -> {
                ready = true
                attempts = 0
                setPhase(if (sink.playing) LivePhase.SPEAKING else LivePhase.LISTENING)
            }
            "audio" -> {
                // While the user speaks the model is not to be heard.
                if (hearing) return
                val pcm =
                    try {
                        Base64.getDecoder().decode(frame.optString("data"))
                    } catch (e: IllegalArgumentException) {
                        return
                    }
                sink.play(pcm)
                setPhase(LivePhase.SPEAKING)
            }
            "caption" -> {
                val role = frame.optString("role")
                val words = frame.optString("text")
                if (role != "user" && role != "assistant" || words.isEmpty()) return
                events(LiveEvent(kind = LiveEventKind.CAPTION, role = role, text = words, isFinal = frame.optBoolean("final")))
            }
            "turn.done" -> {
                if (hearing) return
                if (sink.playing) turnDone = true else setPhase(LivePhase.LISTENING)
            }
            "interrupted" -> sink.stop()
            "ignored" -> if (!hearing && !sink.playing) setPhase(LivePhase.LISTENING)
            "task.run" -> {
                val callId = frame.optString("callId")
                val command = frame.optString("command")
                if (callId.isEmpty() || command.isEmpty()) return
                events(LiveEvent(kind = LiveEventKind.TASK_RUN, callId = callId, text = command))
            }
            "task.amend" -> {
                val words = frame.optString("text")
                if (words.isNotEmpty()) events(LiveEvent(kind = LiveEventKind.TASK_AMEND, text = words))
            }
            "task.stop" -> events(LiveEvent(kind = LiveEventKind.TASK_STOP))
            "error" ->
                when (frame.optString("code")) {
                    "limit_reached" -> {
                        setPhase(LivePhase.LIMIT_REACHED)
                        stop()
                    }
                    "unavailable" -> fallBack()
                }
        }
    }

    @Synchronized
    private fun onDrained() {
        if (!turnDone || hearing) return
        turnDone = false
        if (ready) setPhase(LivePhase.LISTENING)
    }

    private fun send(frame: JSONObject) {
        socket?.send(frame.toString())
    }

    private fun setPhase(next: LivePhase) {
        if (next == phase) return
        phase = next
        events(LiveEvent(kind = LiveEventKind.PHASE, phase = next))
    }

    companion object {
        /** 100 ms of speech per audio frame. */
        const val FRAMES_PER_CHUNK = 5
        const val MAX_ATTEMPTS = 3
        const val RETRY_MS = 1_000L
        const val RETRY_AFTER_FALLBACK_MS = 120_000L
        const val ANSWER_TIMEOUT_MS = 12_000L
        private const val MAX_REPLY = 2_000
    }
}
