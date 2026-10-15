package com.alesle.ai

import com.alesle.ai.agent.AccessibilityStatus
import com.alesle.ai.agent.AgentHostApiImpl
import com.alesle.ai.agent.generated.AgentEventsApi
import com.alesle.ai.agent.generated.AgentHostApi
import com.alesle.ai.agent.task.AgentTaskController
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    private val scope = MainScope()

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
        val events = AgentEventsApi(messenger)
        tasks.listener = { event ->
            // Pigeon sends on the platform thread; a Dart side that is gone is fine to miss.
            scope.launch { runCatching { events.onStepEvent(event) } }
        }
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        AgentTaskController.get(applicationContext).listener = null
        scope.cancel()
        AgentHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, null)
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
