package com.alesle.ai.agent.intent

import android.content.ActivityNotFoundException
import android.content.ContentResolver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.ContactsContract.CommonDataKinds.Phone

/** [ContactsSource] over the contacts provider. */
class ContentResolverContacts(
    private val resolver: ContentResolver,
) : ContactsSource {
    override fun search(query: String): List<ContactPhone> =
        query(
            "${Phone.DISPLAY_NAME} LIKE ? ESCAPE '\\'",
            arrayOf("%" + query.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") + "%"),
        )

    override fun byId(id: Long): ContactPhone? = query("${Phone._ID} = ?", arrayOf(id.toString())).firstOrNull()

    override fun all(): List<ContactPhone> = query(null, null, MAX_ALL_ROWS)

    private fun query(
        selection: String?,
        args: Array<String>?,
        limit: Int = MAX_ROWS,
    ): List<ContactPhone> {
        val projection = arrayOf(Phone._ID, Phone.DISPLAY_NAME, Phone.NUMBER)
        val cursor = resolver.query(Phone.CONTENT_URI, projection, selection, args, "${Phone.DISPLAY_NAME} ASC") ?: return emptyList()
        return cursor.use {
            val result = mutableListOf<ContactPhone>()
            while (it.moveToNext() && result.size < limit) {
                val name = it.getString(1) ?: continue
                val number = it.getString(2) ?: continue
                result += ContactPhone(it.getLong(0), name, number)
            }
            result
        }
    }

    private companion object {
        /** A name like "a" can match the whole address book; the agent only needs the top few. */
        const val MAX_ROWS = 50

        /** Enough for a full address book; names and numbers only, read on the phone. */
        const val MAX_ALL_ROWS = 5_000
    }
}

/** [AppCatalog] over the package manager. */
class PackageManagerApps(
    private val packageManager: PackageManager,
) : AppCatalog {
    override fun launchableApps(): List<InstalledApp> {
        val launcher = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val activities =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.queryIntentActivities(launcher, PackageManager.ResolveInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                packageManager.queryIntentActivities(launcher, 0)
            }
        return activities
            .map { InstalledApp(it.loadLabel(packageManager).toString(), it.activityInfo.packageName) }
            .distinctBy { it.packageName }
    }

    override fun launchIntent(packageName: String): Intent? = packageManager.getLaunchIntentForPackage(packageName)
}

/**
 * [ActivityStarter] on the accessibility service's context, which Android
 * lets start activities from the background while the service is bound.
 */
class ContextActivityStarter(
    private val context: Context,
) : ActivityStarter {
    override fun hasPermission(permission: String): Boolean = context.checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED

    override fun start(intent: Intent): Boolean =
        try {
            context.startActivity(intent)
            true
        } catch (_: ActivityNotFoundException) {
            false
        }
}
