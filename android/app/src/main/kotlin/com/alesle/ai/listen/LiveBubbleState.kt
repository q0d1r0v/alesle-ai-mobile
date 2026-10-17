package com.alesle.ai.listen

import com.alesle.ai.agent.generated.LivePhase

/** How the bubble looks: what the conversation is doing right now. */
enum class BubbleLook { CONNECTING, LISTENING, HEARING, THINKING, SPEAKING, MUTED, PAUSED }

/** Everything the bubble depends on, gathered from the process-wide holders. */
data class BubbleInputs(
    /** The microphone service runs (hands-free is on). */
    val listening: Boolean,
    val muted: Boolean,
    /** [LiveVoice.phase]; null between conversations or in whole-utterance mode. */
    val phase: LivePhase?,
    /** Alesle's own screen is in front: it shows the conversation itself. */
    val appVisible: Boolean,
    /** A task works the screen: its overlay (with STOP) is shown instead, and nothing may cover its taps. */
    val taskRunning: Boolean,
    /** Another app holds the microphone; listening comes back by itself. */
    val paused: Boolean = false,
)

/** Decides whether the live bubble shows and how; pure, so it is tested without windows. */
object LiveBubbleState {
    fun look(inputs: BubbleInputs): BubbleLook? {
        if (!inputs.listening || inputs.appVisible || inputs.taskRunning) return null
        if (inputs.phase == LivePhase.LIMIT_REACHED) return null
        if (inputs.muted) return BubbleLook.MUTED
        if (inputs.paused) return BubbleLook.PAUSED
        return when (inputs.phase) {
            LivePhase.CONNECTING, LivePhase.UNAUTHORIZED -> BubbleLook.CONNECTING
            LivePhase.HEARING -> BubbleLook.HEARING
            LivePhase.THINKING -> BubbleLook.THINKING
            LivePhase.SPEAKING -> BubbleLook.SPEAKING
            // Whole utterances (fallback) listen too.
            LivePhase.LISTENING, LivePhase.FALLBACK, LivePhase.LIMIT_REACHED, null -> BubbleLook.LISTENING
        }
    }

    /** Where a dropped bubble settles: against the nearer side, inside the screen. */
    fun snapX(
        x: Int,
        size: Int,
        screenWidth: Int,
        margin: Int,
    ): Int = if (x + size / 2 < screenWidth / 2) margin else screenWidth - size - margin

    fun clampY(
        y: Int,
        size: Int,
        screenHeight: Int,
        margin: Int,
    ): Int = y.coerceIn(margin, maxOf(margin, screenHeight - size - margin))
}
