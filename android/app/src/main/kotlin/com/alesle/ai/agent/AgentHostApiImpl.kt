package com.alesle.ai.agent

import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.provider.Settings
import com.alesle.ai.agent.debug.DebugCommands
import com.alesle.ai.agent.generated.AgentHostApi
import com.alesle.ai.agent.generated.AgentStatusMessage
import com.alesle.ai.agent.generated.FlutterError
import com.alesle.ai.agent.generated.StartTaskResult
import com.alesle.ai.agent.task.AgentTaskController

/** Kotlin side of the Pigeon `AgentHostApi` contract (pigeons/agent_api.dart). */
class AgentHostApiImpl(
    private val context: Context,
    private val accessibilityStatus: AccessibilityStatus,
    private val tasks: AgentTaskController,
    private val debug: DebugCommands = DebugCommands.shared,
) : AgentHostApi {
    private val debuggable = context.applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE != 0

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

    override fun startTask(command: String): StartTaskResult = tasks.start(command)

    override fun stopTask() = tasks.stop()

    override fun debugSnapshot(): String = debugOnly { debug.snapshot().toString() }

    override fun debugExecute(actionJson: String): String = debugOnly { debug.execute(actionJson).toString() }

    private fun debugOnly(block: () -> String): String {
        // A release build must not hand screen content or remote taps to Dart outside a task.
        if (!debuggable) throw FlutterError("debug_only", "Available in debug builds only")
        return block()
    }
}
