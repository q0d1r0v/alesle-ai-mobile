package com.alesle.ai.listen

import android.content.Context
import com.alesle.ai.agent.generated.ListenHostApi
import com.alesle.ai.agent.generated.ListenStateMessage

/** Kotlin side of the Pigeon `ListenHostApi` contract (pigeons/agent_api.dart). */
class ListenHostApiImpl(
    private val context: Context,
    private val start: (Context) -> Boolean = ListeningService::start,
    private val stop: (Context) -> Unit = ListeningService::stop,
    private val mute: (Context, Boolean) -> Unit = ListeningService::setMuted,
) : ListenHostApi {
    /** Active means the service was asked to start; if the microphone then fails, a state event says so. */
    override fun startListening(): ListenStateMessage {
        val accepted = start(context)
        val state = HandsFree.state
        return ListenStateMessage(active = state.active || accepted, muted = state.muted)
    }

    override fun stopListening() = stop(context)

    override fun setMuted(muted: Boolean) = mute(context, muted)

    override fun listenState(): ListenStateMessage = HandsFree.state.toMessage()
}

fun ListenState.toMessage(): ListenStateMessage = ListenStateMessage(active = active, muted = muted)
