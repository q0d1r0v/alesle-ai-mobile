package com.alesle.ai.listen

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.alesle.ai.AppVisibility
import com.alesle.ai.agent.generated.LiveConfig
import com.alesle.ai.agent.generated.LiveEvent
import com.alesle.ai.agent.generated.LiveEventKind
import com.alesle.ai.agent.generated.LivePhase
import com.alesle.ai.agent.loop.OkHttpLoopSocketFactory
import com.alesle.ai.update.AppVersion
import java.util.concurrent.CopyOnWriteArrayList
import kotlin.math.abs

/**
 * Process-wide holder of the live conversation, shared by the listening
 * service (whose detector feeds it), the Flutter bridge (which starts it and
 * gets its events) and nothing else. Speech goes to the session only while
 * it [handlesSpeech]; otherwise hands-free works one utterance at a time.
 */
object LiveVoice : VoiceActivityDetector.SpeechStream {
    @Volatile
    private var session: LiveSession? = null
    private val listeners = CopyOnWriteArrayList<(LiveEvent) -> Unit>()
    private val main by lazy { Handler(Looper.getMainLooper()) }

    val handlesSpeech: Boolean get() = session?.handlesSpeech == true

    /** The conversation's language (BCP-47), for the bubble's words. */
    @Volatile
    var locale: String? = null
        private set

    /** Where the conversation is; null when there is none. */
    @Volatile
    var phase: LivePhase? = null
        private set

    /** The level last sent to the app. */
    private var sentLevel = 0f

    /** While a conversation is on, the voice level goes to the app's orb a few times a second (only while it is seen). */
    private val levelTick =
        object : Runnable {
            override fun run() {
                if (session == null) return
                val level = VoiceLevel.level
                if (AppVisibility.visible && (abs(level - sentLevel) >= LEVEL_STEP || (level == 0f && sentLevel != 0f))) {
                    sentLevel = level
                    publish(LiveEvent(kind = LiveEventKind.LEVEL, level = level.toDouble()))
                }
                main.postDelayed(this, LEVEL_MS)
            }
        }

    /** Alesle is speaking: barge-in needs louder speech than its own echo. */
    val strict: Boolean get() = session?.strict == true

    @Synchronized
    fun start(
        context: Context,
        config: LiveConfig,
    ) {
        session?.stop()
        locale = config.locale
        LiveBubble.install(context)
        val version = AppVersion.code(context)
        val url = OkHttpLoopSocketFactory.socketUrl(config.apiBaseUrl, PATH)
        session =
            LiveSession(
                socketsFor = { token -> OkHttpLoopSocketFactory(url, token, appVersion = version) },
                token = config.accessToken,
                locale = config.locale,
                sink = LivePlayer(),
                events = ::publish,
                schedule = { delay, block -> main.postDelayed(block, delay) },
            ).also { it.start() }
        main.removeCallbacks(levelTick)
        main.post(levelTick)
    }

    @Synchronized
    fun stop() {
        session?.stop()
        session = null
        phase = null
        main.removeCallbacks(levelTick)
    }

    /** Ended by the user outside the app (the bubble): the app turns hands-free off. */
    fun end(context: Context) {
        val ending = synchronized(this) { session.also { session = null } }
        phase = null
        main.removeCallbacks(levelTick)
        ending?.end() ?: publish(LiveEvent(kind = LiveEventKind.END))
        ListeningService.stop(context)
    }

    private fun publish(event: LiveEvent) {
        if (event.kind == LiveEventKind.PHASE) phase = event.phase
        if (event.kind == LiveEventKind.END) phase = null
        listeners.forEach { it(event) }
    }

    fun updateToken(token: String) {
        session?.updateToken(token)
    }

    fun sendText(text: String) {
        session?.sendText(text)
    }

    fun taskResult(
        callId: String,
        status: String,
        reply: String?,
        reason: String?,
    ) {
        session?.taskResult(callId, status, reply, reason)
    }

    fun onEvent(listener: (LiveEvent) -> Unit): AutoCloseable {
        listeners += listener
        return AutoCloseable { listeners -= listener }
    }

    override fun onSpeechStart(frames: List<ShortArray>) {
        session?.onSpeechStart(frames)
    }

    override fun onSpeechFrame(frame: ShortArray) {
        session?.onSpeechFrame(frame)
    }

    override fun onSpeechEnd(cancelled: Boolean) {
        session?.onSpeechEnd(cancelled)
    }

    const val PATH = "/v1/voice/live"
    private const val LEVEL_MS = 66L
    private const val LEVEL_STEP = 0.03f
}
