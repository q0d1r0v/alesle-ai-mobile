package com.alesle.ai.listen

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.alesle.ai.agent.generated.LiveConfig
import com.alesle.ai.agent.generated.LiveEvent
import com.alesle.ai.agent.loop.OkHttpLoopSocketFactory
import com.alesle.ai.update.AppVersion
import java.util.concurrent.CopyOnWriteArrayList

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

    /** Alesle is speaking: barge-in needs louder speech than its own echo. */
    val strict: Boolean get() = session?.strict == true

    @Synchronized
    fun start(
        context: Context,
        config: LiveConfig,
    ) {
        session?.stop()
        val version = AppVersion.code(context)
        val url = OkHttpLoopSocketFactory.socketUrl(config.apiBaseUrl, PATH)
        session =
            LiveSession(
                socketsFor = { token -> OkHttpLoopSocketFactory(url, token, appVersion = version) },
                token = config.accessToken,
                locale = config.locale,
                sink = LivePlayer(),
                events = { event -> listeners.forEach { it(event) } },
                schedule = { delay, block -> main.postDelayed(block, delay) },
            ).also { it.start() }
    }

    @Synchronized
    fun stop() {
        session?.stop()
        session = null
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
    ) {
        session?.taskResult(callId, status, reply)
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
}
