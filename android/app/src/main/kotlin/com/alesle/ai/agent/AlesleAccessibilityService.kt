package com.alesle.ai.agent

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

/**
 * The agent's eyes and hands on the device.
 *
 * Phase 1 is a deliberate no-op: it only has to exist so the user can enable
 * it and the app can detect that. Phase 5 adds the node-tree snapshot,
 * screenshot fallback, action executor and per-step verification — all of it
 * gated by [ExecutionPolicy].
 */
class AlesleAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // Intentionally empty until phase 5: no screen content is read or kept.
    }

    override fun onInterrupt() {
        // Nothing in flight to cancel yet.
    }
}
