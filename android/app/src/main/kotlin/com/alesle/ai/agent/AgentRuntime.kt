package com.alesle.ai.agent

import com.alesle.ai.agent.action.DeviceControl
import com.alesle.ai.agent.intent.IntentLauncher
import com.alesle.ai.agent.snapshot.CapturedScreen
import com.alesle.ai.agent.vision.Screenshot

/** What the connected AccessibilityService offers the rest of the app; faked in tests. */
interface AgentRuntime {
    /** The current screen, or null when no window is readable (e.g. lock screen). */
    fun capture(): CapturedScreen?

    /** The screen as a picture, for vision (SOW 03 §3). Blocking. */
    fun screenshot(): Screenshot

    val deviceControl: DeviceControl?
    val intentLauncher: IntentLauncher?
}
