package com.alesle.ai

import android.content.Context
import com.alesle.ai.agent.generated.DeviceHostApi
import com.alesle.ai.agent.generated.UpdateHostApi
import com.alesle.ai.device.AudioPlayer
import com.alesle.ai.device.DeviceHostApiImpl
import com.alesle.ai.device.PermissionGate
import com.alesle.ai.device.VoiceRecorder
import com.alesle.ai.update.UpdateHostApiImpl
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

/**
 * Alesle's screen on the process-wide engine ([AppEngine]). Only what needs
 * this activity (permission dialogs, the recorder, updates) is wired here;
 * closing the screen leaves the engine, hands-free and Live running until the
 * user turns them off (the notification, the bubble, or saying goodbye).
 */
class MainActivity : FlutterActivity() {
    private val permissions by lazy { PermissionGate(applicationContext) { this } }
    private val recorder by lazy { VoiceRecorder(applicationContext) }
    private val player by lazy { AudioPlayer() }

    override fun provideFlutterEngine(context: Context): FlutterEngine = AppEngine.get(context)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AppEngine.bridge(flutterEngine, applicationContext)
        val messenger = flutterEngine.dartExecutor.binaryMessenger
        DeviceHostApi.setUp(messenger, DeviceHostApiImpl(applicationContext, permissions, recorder, player))
        UpdateHostApi.setUp(messenger, UpdateHostApiImpl(applicationContext))
    }

    override fun onStart() {
        super.onStart()
        AppVisibility.set(true)
    }

    override fun onStop() {
        AppVisibility.set(false)
        super.onStop()
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
        // The device and update calls stay registered (the next screen replaces them):
        // Dart keeps running, and a call with no handler would fail instead of degrading.
        recorder.cancel()
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
