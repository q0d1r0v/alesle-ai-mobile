package com.alesle.ai.agent.intent

import android.Manifest
import android.app.Application
import android.content.ActivityNotFoundException
import android.content.ComponentName
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.pm.ActivityInfo
import android.content.pm.ResolveInfo
import android.database.MatrixCursor
import android.provider.ContactsContract.CommonDataKinds.Phone
import androidx.test.core.app.ApplicationProvider
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
class AndroidSourcesTest {
    private val app = ApplicationProvider.getApplicationContext<Application>()

    // --- contacts ---

    private fun cursor(vararg rows: Array<Any?>) =
        MatrixCursor(arrayOf(Phone._ID, Phone.DISPLAY_NAME, Phone.NUMBER)).apply { rows.forEach(::addRow) }

    @Test
    fun `searches contacts by name with LIKE wildcards escaped`() {
        val resolver = mockk<ContentResolver>()
        val args = slot<Array<String>>()
        every { resolver.query(Phone.CONTENT_URI, any(), any(), capture(args), any()) } returns
            cursor(arrayOf(1L, "Aziz", "+998901234567"), arrayOf(2L, null, "+1"), arrayOf(3L, "No number", null))

        val found = ContentResolverContacts(resolver).search("50%_a\\b")

        assertEquals(listOf(ContactPhone(1, "Aziz", "+998901234567")), found)
        assertEquals("%50\\%\\_a\\\\b%", args.captured.single())
    }

    @Test
    fun `stops reading after the row cap`() {
        val resolver = mockk<ContentResolver>()
        every { resolver.query(any(), any(), any(), any(), any()) } returns
            cursor(*Array(80) { arrayOf<Any?>(it.toLong(), "A$it", "+$it") })
        assertEquals(50, ContentResolverContacts(resolver).search("a").size)
    }

    @Test
    fun `finds a contact phone by id`() {
        val resolver = mockk<ContentResolver>()
        val args = slot<Array<String>>()
        every { resolver.query(any(), any(), any(), capture(args), any()) } returns cursor(arrayOf(9L, "Aziz", "+998935557788"))
        assertEquals(ContactPhone(9, "Aziz", "+998935557788"), ContentResolverContacts(resolver).byId(9))
        assertEquals("9", args.captured.single())
    }

    @Test
    fun `returns nothing when the provider gives no cursor`() {
        val resolver = mockk<ContentResolver>()
        every { resolver.query(any(), any(), any(), any(), any()) } returns null
        assertEquals(emptyList<ContactPhone>(), ContentResolverContacts(resolver).search("x"))
        assertNull(ContentResolverContacts(resolver).byId(1))
    }

    // --- apps ---

    private fun registerLauncherApp(
        label: String,
        packageName: String,
    ) {
        val info =
            ResolveInfo().apply {
                nonLocalizedLabel = label
                activityInfo =
                    ActivityInfo().apply {
                        this.packageName = packageName
                        name = "$packageName.Main"
                    }
            }
        val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        // Deprecated in Robolectric, but the only hook that takes a ResolveInfo with its own label.
        @Suppress("DEPRECATION")
        shadowOf(app.packageManager).addResolveInfoForIntent(launcher, info)
    }

    @Test
    fun `lists launchable apps once per package`() {
        registerLauncherApp("Telegram", "org.telegram.messenger")
        registerLauncherApp("Telegram again", "org.telegram.messenger")
        registerLauncherApp("Uzum Market", "uz.uzum.app")
        // Robolectric also lists this app's own launcher activity, as a real phone would.
        val apps = PackageManagerApps(app.packageManager).launchableApps().filter { it.packageName != app.packageName }
        assertEquals(listOf("org.telegram.messenger", "uz.uzum.app"), apps.map { it.packageName })
        assertEquals("Telegram", apps.first().label)
    }

    @Test
    @Config(sdk = [30])
    fun `lists launchable apps on Android 11`() {
        registerLauncherApp("Telegram", "org.telegram.messenger")
        val packages = PackageManagerApps(app.packageManager).launchableApps().map { it.packageName }
        assertEquals(listOf("org.telegram.messenger", app.packageName), packages)
    }

    @Test
    fun `has no launch intent for an unknown package`() {
        assertNull(PackageManagerApps(app.packageManager).launchIntent("not.installed"))
    }

    // --- starter ---

    @Test
    fun `starts activities and checks permissions on the context`() {
        val starter = ContextActivityStarter(app)
        assertFalse(starter.hasPermission(Manifest.permission.READ_CONTACTS))
        shadowOf(app).grantPermissions(Manifest.permission.READ_CONTACTS)
        assertTrue(starter.hasPermission(Manifest.permission.READ_CONTACTS))

        val intent = Intent(Intent.ACTION_VIEW).setComponent(ComponentName("x", "x.Y")).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        assertTrue(starter.start(intent))
        assertEquals(intent, shadowOf(app).nextStartedActivity)
    }

    @Test
    fun `reports an intent no app handles`() {
        val context = mockk<Context>()
        every { context.startActivity(any()) } throws ActivityNotFoundException()
        assertFalse(ContextActivityStarter(context).start(Intent(Intent.ACTION_VIEW)))
    }
}
