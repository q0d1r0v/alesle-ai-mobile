package com.alesle.ai.device

import android.annotation.SuppressLint
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.net.toUri
import com.alesle.ai.agent.generated.DeviceHostApi
import com.alesle.ai.agent.generated.DeviceSetupMessage
import com.alesle.ai.agent.generated.PermissionKind
import com.alesle.ai.agent.generated.PermissionState
import java.util.Locale

/** Kotlin side of the Pigeon `DeviceHostApi`: onboarding checks and push-to-talk audio. */
class DeviceHostApiImpl(
    private val context: Context,
    private val permissions: PermissionGate,
    private val recorder: VoiceRecorder,
    private val player: AudioPlayer,
    private val manufacturer: String = Build.MANUFACTURER,
    private val model: String = Build.MODEL,
) : DeviceHostApi {
    override fun permissionState(kind: PermissionKind): PermissionState = permissions.state(kind)

    override suspend fun requestPermission(kind: PermissionKind): PermissionState = permissions.request(kind)

    override fun setupState(): DeviceSetupMessage {
        val power = context.getSystemService(PowerManager::class.java)
        return DeviceSetupMessage(
            batteryOptimizationIgnored = power?.isIgnoringBatteryOptimizations(context.packageName) ?: false,
            manufacturer = manufacturer.lowercase(Locale.ROOT),
            sdkInt = Build.VERSION.SDK_INT.toLong(),
            deviceName = deviceName(manufacturer, model),
        )
    }

    override fun openAppDetails() {
        start(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, "package:${context.packageName}".toUri()))
    }

    // Not on Google Play (ADR 0005); an assistant that Android stops mid-task fails the user (SOW 03 §8.1).
    @SuppressLint("BatteryLife")
    override fun requestIgnoreBatteryOptimizations() {
        val asked = start(Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, "package:${context.packageName}".toUri()))
        if (!asked) start(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
    }

    override fun openAutostartSettings(): Boolean {
        val screen = AUTOSTART[manufacturer.lowercase(Locale.ROOT)]
        if (screen != null && start(Intent().setComponent(screen))) return true
        openAppDetails()
        return false
    }

    override fun startRecording() = recorder.start()

    override fun stopRecording(): String? = recorder.stop()

    override fun cancelRecording() = recorder.cancel()

    override fun playAudio(path: String) = player.play(path)

    override fun stopAudio() = player.stop()

    private fun start(intent: Intent): Boolean =
        try {
            context.startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
            true
        } catch (e: ActivityNotFoundException) {
            false
        } catch (e: SecurityException) {
            // Some OEM screens are not exported on every build.
            false
        }

    companion object {
        /** OEM screens that decide whether an app may run in the background (SOW 03 §8.1). */
        val AUTOSTART: Map<String, ComponentName> =
            mapOf(
                "xiaomi" to ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
                "redmi" to ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
                "poco" to ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity"),
                "oppo" to ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
                "realme" to ComponentName("com.coloros.safecenter", "com.coloros.safecenter.permission.startup.StartupAppListActivity"),
                "vivo" to ComponentName("com.vivo.permissionmanager", "com.vivo.permissionmanager.activity.BgStartUpManagerActivity"),
                "huawei" to
                    ComponentName(
                        "com.huawei.systemmanager",
                        "com.huawei.systemmanager.startupmgr.ui.StartupNormalAppListActivity",
                    ),
                "honor" to
                    ComponentName("com.hihonor.systemmanager", "com.hihonor.systemmanager.startupmgr.ui.StartupNormalAppListActivity"),
            )
    }
}

/** "Google Pixel 7"; a model that already starts with the maker is left as it is. */
internal fun deviceName(
    manufacturer: String,
    model: String,
): String {
    val maker = manufacturer.replaceFirstChar { it.titlecase(Locale.ROOT) }
    return if (model.startsWith(manufacturer, ignoreCase = true)) model else "$maker $model".trim()
}
