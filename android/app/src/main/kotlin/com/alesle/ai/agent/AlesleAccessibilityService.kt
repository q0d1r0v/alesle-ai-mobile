package com.alesle.ai.agent

import android.accessibilityservice.AccessibilityService
import android.content.res.Configuration
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityWindowInfo
import com.alesle.ai.agent.snapshot.AccessibilityUiNode
import com.alesle.ai.agent.snapshot.Bounds
import com.alesle.ai.agent.snapshot.Orientation
import com.alesle.ai.agent.snapshot.ScreenSnapshot
import com.alesle.ai.agent.snapshot.SnapshotBuilder
import com.alesle.ai.agent.snapshot.SnapshotContext

/**
 * The agent's eyes and hands on the device.
 *
 * Reads the screen only when asked ([captureSnapshot]); events are used just
 * to remember which window class is in front. No screen content is kept.
 */
class AlesleAccessibilityService : AccessibilityService() {
    private val snapshotBuilder = SnapshotBuilder()

    /** Package and class of the last window-state change: the "activity". */
    @Volatile
    private var foreground: Pair<String, String>? = null

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
    }

    override fun onDestroy() {
        if (instance === this) instance = null
        super.onDestroy()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return
        val pkg = event.packageName?.toString() ?: return
        val cls = event.className?.toString() ?: return
        foreground = pkg to cls
    }

    override fun onInterrupt() {
        // Nothing in flight to cancel yet.
    }

    /** The current screen, or null when no window is readable (e.g. lock screen). */
    fun captureSnapshot(): ScreenSnapshot? {
        val root = rootInActiveWindow ?: return null
        val packageName = root.packageName?.toString() ?: return null
        val metrics = resources.displayMetrics
        val configuration = resources.configuration
        val context =
            SnapshotContext(
                packageName = packageName,
                activity = foreground?.takeIf { it.first == packageName }?.second,
                locale = configuration.locales[0].toLanguageTag(),
                orientation =
                    if (configuration.orientation == Configuration.ORIENTATION_LANDSCAPE) {
                        Orientation.LANDSCAPE
                    } else {
                        Orientation.PORTRAIT
                    },
                keyboardVisible = windows.any { it.type == AccessibilityWindowInfo.TYPE_INPUT_METHOD },
                screen = Bounds(0, 0, metrics.widthPixels, metrics.heightPixels),
            )
        return snapshotBuilder.build(AccessibilityUiNode(root), context)
    }

    companion object {
        /** The connected service, or null while the user has it switched off. */
        @Volatile
        var instance: AlesleAccessibilityService? = null
            private set
    }
}
