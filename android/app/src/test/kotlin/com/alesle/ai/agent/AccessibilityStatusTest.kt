package com.alesle.ai.agent

import android.content.ComponentName
import android.provider.Settings
import androidx.test.core.app.ApplicationProvider
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class AccessibilityStatusTest {
    private val context = ApplicationProvider.getApplicationContext<android.app.Application>()
    private val ours = ComponentName(context, AlesleAccessibilityService::class.java)

    @Test
    fun `null or blank setting means disabled`() {
        assertFalse(AccessibilityStatus.isComponentEnabled(null, ours))
        assertFalse(AccessibilityStatus.isComponentEnabled("  ", ours))
    }

    @Test
    fun `matches the long and the short flattened forms`() {
        assertTrue(AccessibilityStatus.isComponentEnabled(ours.flattenToString(), ours))
        assertTrue(AccessibilityStatus.isComponentEnabled(ours.flattenToShortString(), ours))
    }

    @Test
    fun `finds our service among others and ignores garbage entries`() {
        val setting = "com.other/.Service:not-a-component:${ours.flattenToString()}"
        assertTrue(AccessibilityStatus.isComponentEnabled(setting, ours))
    }

    @Test
    fun `another app's service with the same class name does not count`() {
        val impostor = ComponentName("com.evil", AlesleAccessibilityService::class.java.name)
        assertFalse(AccessibilityStatus.isComponentEnabled(impostor.flattenToString(), ours))
    }

    @Test
    fun `reads the real secure setting`() {
        val status = AccessibilityStatus(context)
        Settings.Secure.putString(context.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES, "")
        assertFalse(status.isServiceEnabled())

        Settings.Secure.putString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
            ours.flattenToString(),
        )
        assertTrue(status.isServiceEnabled())
    }
}
