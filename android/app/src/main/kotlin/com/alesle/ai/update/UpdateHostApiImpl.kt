package com.alesle.ai.update

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageInstaller
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.util.Log
import androidx.core.net.toUri
import com.alesle.ai.agent.generated.AppVersionMessage
import com.alesle.ai.agent.generated.InstallOutcome
import com.alesle.ai.agent.generated.UpdateHostApi
import kotlinx.coroutines.CoroutineDispatcher
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File
import java.io.IOException

/**
 * In-app update (SOW 02 §3, AC-APP-6): installs a downloaded APK only when it
 * is a newer com.alesle.ai signed with this build's certificate. Dart has
 * already checked the file's SHA-256 against the manifest.
 */
class UpdateHostApiImpl(
    private val context: Context,
    private val io: CoroutineDispatcher = Dispatchers.IO,
    private val archiveInfo: (String) -> PackageInfo? = { path -> readArchive(context.packageManager, path) },
    private val signers: (PackageInfo) -> List<String> = AppVersion::signerHashes,
    private val ownCode: () -> Long = { AppVersion.code(context) },
    private val ownCert: () -> String = { AppVersion.certSha256(context) },
) : UpdateHostApi {
    override fun appVersion(): AppVersionMessage =
        AppVersionMessage(
            versionCode = ownCode(),
            versionName = AppVersion.name(context),
            certSha256 = ownCert(),
        )

    override suspend fun install(
        path: String,
        expectedCertSha256: String,
    ): InstallOutcome =
        withContext(io) {
            try {
                check(path, expectedCertSha256) ?: commit(File(path))
            } catch (e: IOException) {
                failed(e)
            } catch (e: SecurityException) {
                failed(e)
            } catch (e: IllegalStateException) {
                failed(e)
            }
        }

    /** Why the file must not be installed, or null when it may. */
    internal fun check(
        path: String,
        expectedCertSha256: String,
    ): InstallOutcome? {
        if (!File(path).isFile) return InstallOutcome.REJECTED
        val archive = archiveInfo(path) ?: return InstallOutcome.REJECTED
        if (archive.packageName != context.packageName) return InstallOutcome.REJECTED
        if (archive.longVersionCode <= ownCode()) return InstallOutcome.REJECTED
        val own = ownCert()
        val expected = expectedCertSha256.lowercase()
        if (own.isEmpty() || expected != own || own !in signers(archive)) return InstallOutcome.REJECTED
        if (!context.packageManager.canRequestPackageInstalls()) {
            context.startActivity(
                Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, "package:${context.packageName}".toUri())
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
            )
            return InstallOutcome.PERMISSION_NEEDED
        }
        return null
    }

    private fun commit(file: File): InstallOutcome {
        val installer = context.packageManager.packageInstaller
        val params =
            PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL).apply {
                setAppPackageName(context.packageName)
            }
        val id = installer.createSession(params)
        installer.openSession(id).use { session ->
            file.inputStream().use { input ->
                session.openWrite("alesle.apk", 0, file.length()).use { output ->
                    input.copyTo(output)
                    session.fsync(output)
                }
            }
            // Mutable: the installer fills in the status and the confirmation intent.
            val result =
                PendingIntent.getBroadcast(
                    context,
                    id,
                    Intent(context, InstallResultReceiver::class.java).setPackage(context.packageName),
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
                )
            session.commit(result.intentSender)
        }
        return InstallOutcome.STARTED
    }

    private fun failed(error: Exception): InstallOutcome {
        Log.w(TAG, "Update not installed: ${error.javaClass.simpleName}")
        return InstallOutcome.FAILED
    }

    companion object {
        private const val TAG = "AlesleUpdate"

        fun readArchive(
            pm: PackageManager,
            path: String,
        ): PackageInfo? =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getPackageArchiveInfo(path, PackageManager.PackageInfoFlags.of(PackageManager.GET_SIGNING_CERTIFICATES.toLong()))
            } else {
                @Suppress("DEPRECATION")
                pm.getPackageArchiveInfo(path, PackageManager.GET_SIGNING_CERTIFICATES)
            }
    }
}
