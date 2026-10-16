package com.alesle.ai.update

import android.app.Application
import android.content.Intent
import android.content.pm.PackageInfo
import android.provider.Settings
import androidx.test.core.app.ApplicationProvider
import com.alesle.ai.agent.generated.InstallOutcome
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf

@RunWith(RobolectricTestRunner::class)
class UpdateHostApiImplTest {
    @get:Rule val folder = TemporaryFolder()

    private val context = ApplicationProvider.getApplicationContext<Application>()
    private val cert = "c".repeat(64)

    private fun archive(
        packageName: String = context.packageName,
        versionCode: Long = 2,
    ) = PackageInfo().apply {
        this.packageName = packageName
        longVersionCode = versionCode
    }

    private fun api(
        archive: PackageInfo?,
        signers: List<String> = listOf(cert),
        ownCert: String = cert,
    ) = UpdateHostApiImpl(
        context,
        io = Dispatchers.Unconfined,
        archiveInfo = { archive },
        signers = { signers },
        ownCode = { 1L },
        ownCert = { ownCert },
    )

    private fun apk() = folder.newFile("alesle.apk").apply { writeBytes(byteArrayOf(1, 2, 3)) }.path

    @Test
    fun `reports this build's version and certificate`() {
        val version = api(null).appVersion()
        assertEquals(1L, version.versionCode)
        assertEquals(cert, version.certSha256)
    }

    @Test
    fun `refuses a missing file, a foreign or older package, and another signer`() {
        assertEquals(InstallOutcome.REJECTED, api(archive()).check("/nope.apk", cert))
        val path = apk()
        assertEquals(InstallOutcome.REJECTED, api(null).check(path, cert))
        assertEquals(InstallOutcome.REJECTED, api(archive(packageName = "com.evil")).check(path, cert))
        assertEquals(InstallOutcome.REJECTED, api(archive(versionCode = 1)).check(path, cert))
        assertEquals(InstallOutcome.REJECTED, api(archive(), signers = listOf("d".repeat(64))).check(path, cert))
        // The manifest must name this build's certificate too.
        assertEquals(InstallOutcome.REJECTED, api(archive()).check(path, "d".repeat(64)))
        assertEquals(InstallOutcome.REJECTED, api(archive(), ownCert = "").check(path, ""))
    }

    @Test
    fun `asks for the install permission first`() {
        shadowOf(context.packageManager).setCanRequestPackageInstalls(false)
        assertEquals(InstallOutcome.PERMISSION_NEEDED, api(archive()).check(apk(), cert.uppercase()))
        val opened: Intent = shadowOf(context).nextStartedActivity
        assertEquals(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, opened.action)
        assertEquals("package:${context.packageName}", opened.dataString)
    }

    @Test
    fun `a matching newer Alesle may be installed`() {
        shadowOf(context.packageManager).setCanRequestPackageInstalls(true)
        assertNull(api(archive()).check(apk(), cert))
    }

    @Test
    fun `install answers rejected without touching the installer`() =
        runBlocking {
            assertEquals(InstallOutcome.REJECTED, api(null).install(apk(), cert))
            assertTrue(
                context.packageManager.packageInstaller.allSessions
                    .isEmpty(),
            )
        }

    @Test
    fun `install hands a checked file to the installer`() =
        runBlocking {
            shadowOf(context.packageManager).setCanRequestPackageInstalls(true)
            assertEquals(InstallOutcome.STARTED, api(archive()).install(apk(), cert))
            assertEquals(1, context.packageManager.packageInstaller.allSessions.size)
        }

    @Test
    fun `computes certificate hashes as lowercase hex`() {
        assertEquals(
            "039058c6f2c0cb492c533b0a4d14ef77cc0f78abccced5287d84a1a2011cfb81",
            AppVersion.sha256(byteArrayOf(1, 2, 3)),
        )
        assertTrue(AppVersion.signerHashes(PackageInfo()).isEmpty())
    }
}
