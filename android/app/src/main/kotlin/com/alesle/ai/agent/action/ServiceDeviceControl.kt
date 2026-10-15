package com.alesle.ai.agent.action

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.os.Handler
import com.alesle.ai.agent.snapshot.CapturedScreen
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean

/**
 * [DeviceControl] on top of the running AccessibilityService. Gesture
 * callbacks arrive on [callbackHandler] (a worker looper), so a caller
 * blocked in [performGesture] cannot deadlock the main thread.
 */
class ServiceDeviceControl(
    private val service: AccessibilityService,
    private val callbackHandler: Handler,
    private val capturer: () -> CapturedScreen?,
) : DeviceControl {
    override fun capture(): CapturedScreen? = capturer()

    override fun performGlobal(action: GlobalAction): Boolean =
        service.performGlobalAction(
            when (action) {
                GlobalAction.BACK -> AccessibilityService.GLOBAL_ACTION_BACK
                GlobalAction.HOME -> AccessibilityService.GLOBAL_ACTION_HOME
                GlobalAction.RECENTS -> AccessibilityService.GLOBAL_ACTION_RECENTS
            },
        )

    override fun performGesture(gesture: Gesture): Boolean {
        val description = toDescription(gesture) ?: return false
        val done = CountDownLatch(1)
        val completed = AtomicBoolean(false)
        val callback =
            object : AccessibilityService.GestureResultCallback() {
                override fun onCompleted(gestureDescription: GestureDescription?) {
                    completed.set(true)
                    done.countDown()
                }

                override fun onCancelled(gestureDescription: GestureDescription?) {
                    done.countDown()
                }
            }
        if (!service.dispatchGesture(description, callback, callbackHandler)) return false
        return done.await(gesture.durationMs + GESTURE_TIMEOUT_MS, TimeUnit.MILLISECONDS) && completed.get()
    }

    companion object {
        /** Slack on top of the stroke's own duration before giving up. */
        const val GESTURE_TIMEOUT_MS = 2_000L

        /** Null for an empty stroke; coordinates are clamped to be non-negative, as the API requires. */
        internal fun toDescription(gesture: Gesture): GestureDescription? {
            val first = gesture.points.firstOrNull() ?: return null
            val path =
                Path().apply {
                    moveTo(first.x.coerceAtLeast(0f), first.y.coerceAtLeast(0f))
                    gesture.points.drop(1).forEach { lineTo(it.x.coerceAtLeast(0f), it.y.coerceAtLeast(0f)) }
                }
            val stroke = GestureDescription.StrokeDescription(path, 0, gesture.durationMs.coerceAtLeast(1))
            return GestureDescription.Builder().addStroke(stroke).build()
        }
    }
}
