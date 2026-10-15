package com.alesle.ai.agent

import android.content.Context
import android.content.Intent
import android.provider.Settings
import com.alesle.ai.agent.generated.AgentHostApi
import com.alesle.ai.agent.generated.AgentStatusMessage

/** Kotlin side of the Pigeon `AgentHostApi` contract (pigeons/agent_api.dart). */
class AgentHostApiImpl(
    private val context: Context,
    private val accessibilityStatus: AccessibilityStatus,
) : AgentHostApi {
    override fun getStatus(): AgentStatusMessage =
        AgentStatusMessage(
            accessibilityEnabled = accessibilityStatus.isServiceEnabled(),
        )

    override fun openAccessibilitySettings() {
        // Started from the application context, so it needs its own task.
        val intent =
            Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        context.startActivity(intent)
    }
}
