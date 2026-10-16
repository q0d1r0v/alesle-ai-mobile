package com.alesle.ai.listen

import android.os.SystemClock
import java.util.concurrent.CopyOnWriteArrayList

/** What the listening service reports to the app. */
data class ListenState(
    val active: Boolean,
    val muted: Boolean,
)

/**
 * Process-wide hands-free state, shared by the listening service, the audio
 * player (Alesle's own voice must not be heard as a command) and the Flutter
 * bridge. Listeners are called on whichever thread changed the state.
 */
object HandsFree {
    @Volatile
    var state = ListenState(active = false, muted = false)
        private set

    /** Until when Alesle's own voice is (or just was) playing: uptime ms. */
    @Volatile
    private var speakingUntil = 0L

    @Volatile
    private var speaking = false

    private val stateListeners = CopyOnWriteArrayList<(ListenState) -> Unit>()
    private val utteranceListeners = CopyOnWriteArrayList<(String) -> Unit>()

    fun update(next: ListenState) {
        if (next == state) return
        state = next
        stateListeners.forEach { it(next) }
    }

    /** True while frames must be dropped: muted, or Alesle is speaking (plus a short tail). */
    fun isQuiet(now: Long = SystemClock.uptimeMillis()): Boolean = state.muted || speaking || now < speakingUntil

    /** The player started (true) or finished (false) Alesle's spoken reply. */
    fun setSpeaking(
        playing: Boolean,
        now: Long = SystemClock.uptimeMillis(),
    ) {
        speaking = playing
        if (!playing) speakingUntil = now + ECHO_TAIL_MS
    }

    /** A recorded utterance, as a WAV file in the app cache; the receiver deletes it. */
    fun deliver(path: String) {
        utteranceListeners.forEach { it(path) }
    }

    fun onState(listener: (ListenState) -> Unit): AutoCloseable {
        stateListeners += listener
        return AutoCloseable { stateListeners -= listener }
    }

    fun onUtterance(listener: (String) -> Unit): AutoCloseable {
        utteranceListeners += listener
        return AutoCloseable { utteranceListeners -= listener }
    }

    /** Room echo after the last word of a reply. */
    const val ECHO_TAIL_MS = 500L
}
