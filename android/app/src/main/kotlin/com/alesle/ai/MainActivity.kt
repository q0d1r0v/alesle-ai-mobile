package com.alesle.ai

import com.alesle.ai.agent.AccessibilityStatus
import com.alesle.ai.agent.AgentHostApiImpl
import com.alesle.ai.agent.generated.AgentHostApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AgentHostApi.setUp(
            flutterEngine.dartExecutor.binaryMessenger,
            AgentHostApiImpl(
                context = applicationContext,
                accessibilityStatus = AccessibilityStatus(applicationContext),
            ),
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        AgentHostApi.setUp(flutterEngine.dartExecutor.binaryMessenger, null)
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
