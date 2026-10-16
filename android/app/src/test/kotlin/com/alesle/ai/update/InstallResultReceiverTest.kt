package com.alesle.ai.update

import android.app.Application
import android.content.ComponentName
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageInstaller
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

@RunWith(RobolectricTestRunner::class)
class InstallResultReceiverTest {
    private val context = ApplicationProvider.getApplicationContext<Application>()

    private fun resolvesTo(
        intent: Intent,
        system: Boolean,
    ) {
        val pkg = if (system) "com.google.android.packageinstaller" else "com.evil.installer"
        val pm = shadowOf(context.packageManager)
        pm.installPackage(
            PackageInfo().apply {
                packageName = pkg
                applicationInfo =
                    ApplicationInfo().apply {
                        packageName = pkg
                        flags = if (system) ApplicationInfo.FLAG_SYSTEM else 0
                    }
            },
        )
        val component = ComponentName(pkg, "$pkg.Confirm")
        pm.addActivityIfNotPresent(component)
        pm.addIntentFilterForActivity(component, IntentFilter(intent.action).apply { addCategory(Intent.CATEGORY_DEFAULT) })
    }

    @Test
    fun `starts a confirmation only when the system installer handles it`() {
        val fake = Intent("com.evil.CONFIRM")
        resolvesTo(fake, system = false)
        InstallResultReceiver().onReceive(
            context,
            Intent()
                .putExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_PENDING_USER_ACTION)
                .putExtra(Intent.EXTRA_INTENT, fake),
        )
        assertNull(shadowOf(context).nextStartedActivity)
    }

    @Test
    fun `shows the system confirmation when the installer asks`() {
        val confirm = Intent("android.content.pm.action.CONFIRM_INSTALL")
        resolvesTo(confirm, system = true)
        InstallResultReceiver().onReceive(
            context,
            Intent()
                .putExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_PENDING_USER_ACTION)
                .putExtra(Intent.EXTRA_INTENT, confirm),
        )
        val started = shadowOf(context).nextStartedActivity
        assertEquals("android.content.pm.action.CONFIRM_INSTALL", started.action)
        assertTrue(started.flags and Intent.FLAG_ACTIVITY_NEW_TASK != 0)
    }

    @Test
    fun `success and failure start nothing`() {
        InstallResultReceiver().onReceive(context, Intent().putExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_SUCCESS))
        InstallResultReceiver().onReceive(context, Intent().putExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_FAILURE))
        InstallResultReceiver().onReceive(
            context,
            Intent().putExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_PENDING_USER_ACTION),
        )
        assertNull(shadowOf(context).nextStartedActivity)
    }
}
