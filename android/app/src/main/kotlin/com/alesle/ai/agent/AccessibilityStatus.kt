package com.alesle.ai.agent

import android.content.ComponentName
import android.content.Context
import android.provider.Settings

/**
 * Whether the user has enabled Alesle's AccessibilityService.
 *
 * Reads the system setting rather than a flag set by the service itself: the
 * service is only bound while enabled, so a flag would go stale the moment the
 * user disables it and the process is killed.
 */
open class AccessibilityStatus(
    private val context: Context,
) {
    open fun isServiceEnabled(): Boolean {
        val setting =
            Settings.Secure.getString(
                context.contentResolver,
                Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
            )
        return isComponentEnabled(setting, ComponentName(context, AlesleAccessibilityService::class.java))
    }

    companion object {
        /**
         * `setting` is a colon-separated list of flattened component names, in
         * either the short (`pkg/.Cls`) or long (`pkg/pkg.Cls`) form.
         */
        fun isComponentEnabled(
            setting: String?,
            component: ComponentName,
        ): Boolean {
            if (setting.isNullOrBlank()) return false
            return setting
                .split(':')
                .asSequence()
                .mapNotNull { ComponentName.unflattenFromString(it.trim()) }
                .any { it == component }
        }
    }
}
