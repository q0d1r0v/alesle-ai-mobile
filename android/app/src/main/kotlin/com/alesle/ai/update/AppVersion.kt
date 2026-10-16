package com.alesle.ai.update

import android.content.Context
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Build
import java.security.MessageDigest

/** This build's version and signing certificate (SOW 02 §3). */
object AppVersion {
    fun code(context: Context): Long = info(context, 0).longVersionCode

    fun name(context: Context): String = info(context, 0).versionName ?: ""

    /** Lowercase hex SHA-256 of the certificate this build is signed with; "" when unreadable. */
    fun certSha256(context: Context): String = signerHashes(info(context, PackageManager.GET_SIGNING_CERTIFICATES)).firstOrNull() ?: ""

    /** The certificates the APK's contents are signed with, as lowercase hex SHA-256. */
    fun signerHashes(info: PackageInfo?): List<String> =
        info
            ?.signingInfo
            ?.apkContentsSigners
            ?.map { sha256(it.toByteArray()) }
            .orEmpty()

    fun sha256(bytes: ByteArray): String = MessageDigest.getInstance("SHA-256").digest(bytes).joinToString("") { "%02x".format(it) }

    private fun info(
        context: Context,
        flags: Int,
    ): PackageInfo {
        val pm = context.packageManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.getPackageInfo(context.packageName, PackageManager.PackageInfoFlags.of(flags.toLong()))
        } else {
            @Suppress("DEPRECATION")
            pm.getPackageInfo(context.packageName, flags)
        }
    }
}
