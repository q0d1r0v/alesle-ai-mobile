package com.alesle.ai.listen

import android.content.Context
import com.alesle.ai.agent.generated.ListenHostApi
import com.alesle.ai.agent.generated.ListenStateMessage
import com.alesle.ai.agent.generated.LiveConfig

/** Kotlin side of the Pigeon `ListenHostApi` contract (pigeons/agent_api.dart). */
class ListenHostApiImpl(
    private val context: Context,
    private val start: (Context) -> Boolean = ListeningService::start,
    private val stop: (Context) -> Unit = ListeningService::stop,
    private val mute: (Context, Boolean) -> Unit = ListeningService::setMuted,
    private val live: LiveControl = LiveControl.Default,
) : ListenHostApi {
    /** Active means the service was asked to start; if the microphone then fails, a state event says so. */
    override fun startListening(): ListenStateMessage {
        val accepted = start(context)
        val state = HandsFree.state
        return ListenStateMessage(active = state.active || accepted, muted = state.muted, paused = state.paused)
    }

    override fun stopListening() = stop(context)

    override fun setMuted(muted: Boolean) = mute(context, muted)

    override fun listenState(): ListenStateMessage = HandsFree.state.toMessage()

    override fun startLive(config: LiveConfig): ListenStateMessage {
        live.start(context, config)
        val state = startListening()
        if (!state.active) live.stop()
        return state
    }

    override fun updateLiveToken(accessToken: String) = live.updateToken(accessToken)

    override fun sendLiveText(text: String) = live.sendText(text)

    override fun liveTaskResult(
        callId: String,
        status: String,
        reply: String?,
        reason: String?,
    ) = live.taskResult(callId, status, reply, reason)
}

/** [LiveVoice] behind an interface, for tests. */
interface LiveControl {
    fun start(
        context: Context,
        config: LiveConfig,
    )

    fun stop()

    fun updateToken(token: String)

    fun sendText(text: String)

    fun taskResult(
        callId: String,
        status: String,
        reply: String?,
        reason: String?,
    )

    object Default : LiveControl {
        override fun start(
            context: Context,
            config: LiveConfig,
        ) = LiveVoice.start(context, config)

        override fun stop() = LiveVoice.stop()

        override fun updateToken(token: String) = LiveVoice.updateToken(token)

        override fun sendText(text: String) = LiveVoice.sendText(text)

        override fun taskResult(
            callId: String,
            status: String,
            reply: String?,
            reason: String?,
        ) = LiveVoice.taskResult(callId, status, reply, reason)
    }
}

fun ListenState.toMessage(): ListenStateMessage = ListenStateMessage(active = active, muted = muted, paused = paused)
