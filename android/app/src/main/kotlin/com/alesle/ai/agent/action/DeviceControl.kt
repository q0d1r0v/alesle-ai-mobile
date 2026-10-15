package com.alesle.ai.agent.action

import com.alesle.ai.agent.snapshot.CapturedScreen

/** A point in screen pixels. */
data class PixelPoint(
    val x: Float,
    val y: Float,
)

/** A single-finger stroke: a tap is one point, a swipe two. */
data class Gesture(
    val points: List<PixelPoint>,
    val durationMs: Long,
)

/**
 * What the executor needs from the AccessibilityService, so it can be tested
 * without one. Implementations may block; never call them on the main thread.
 */
interface DeviceControl {
    /** A fresh capture of the screen, or null when nothing is readable. */
    fun capture(): CapturedScreen?

    fun performGlobal(action: GlobalAction): Boolean

    /** Blocks until the gesture completes; false if cancelled or timed out. */
    fun performGesture(gesture: Gesture): Boolean
}
