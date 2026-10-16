package com.alesle.ai

import com.alesle.ai.agent.AccessibilityStatus
import com.alesle.ai.agent.AgentHostApiImpl
import com.alesle.ai.agent.generated.AgentEventsApi
import com.alesle.ai.agent.generated.AgentHostApi
import com.alesle.ai.agent.generated.DeviceHostApi
import com.alesle.ai.agent.generated.UpdateHostApi
import com.alesle.ai.agent.task.AgentTaskController
import com.alesle.ai.device.AudioPlayer
import com.alesle.ai.device.DeviceHostApiImpl
import com.alesle.ai.device.PermissionGate
import com.alesle.ai.device.VoiceRecorder
import com.alesle.ai.update.UpdateHostApiImpl
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private val scope = MainScope()
    private val permissions by lazy { PermissionGate(applicationContext) { this } }
    private val recorder by lazy { VoiceRecorder(applicationContext) }
    private val player by lazy { AudioPlayer() }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val tasks = AgentTaskController.get(applicationContext)
        AgentHostApi.setUp(
            messenger,
            AgentHostApiImpl(
                context = applicationContext,
                accessibilityStatus = AccessibilityStatus(applicationContext),
                tasks = tasks,
            ),
        )
        DeviceHostApi.setUp(messenger, DeviceHostApiImpl(applicationContext, permissions, recorder, player))
        UpdateHostApi.setUp(messenger, UpdateHostApiImpl(applicationContext))
        val events = AgentEventsApi(messenger)
        tasks.listener = { event ->
            // Pigeon sends on the platform thread; a Dart side that is gone is fine to miss.
            scope.launch { runCatching { events.onStepEvent(event) } }
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        this.permissions.onResult(requestCode)
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        AgentTaskController.get(applicationContext).listener = null
        scope.cancel()
        recorder.cancel()
        player.stop()
        AgentHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, null)
        DeviceHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, null)
        UpdateHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, null)
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
