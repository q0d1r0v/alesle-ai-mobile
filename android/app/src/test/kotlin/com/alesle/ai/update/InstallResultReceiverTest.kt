package com.alesle.ai.update

import android.app.Application
import android.content.Intent
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

    @Test
    fun `shows the system confirmation when the installer asks`() {
        val confirm = Intent("android.content.pm.action.CONFIRM_INSTALL")
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
