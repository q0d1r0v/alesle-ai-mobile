package com.alesle.ai.agent.intent

import android.content.Intent

/** One phone number of one contact; [id] is the contacts-provider data row id. */
data class ContactPhone(
    val id: Long,
    val name: String,
    val number: String,
)

data class InstalledApp(
    val label: String,
    val packageName: String,
)

/** The phone's contacts. Throws [SecurityException] without READ_CONTACTS. */
interface ContactsSource {
    /** Phones whose contact name contains [query], ignoring case. */
    fun search(query: String): List<ContactPhone>

    fun byId(id: Long): ContactPhone?

    /** Every phone in the contacts (capped): for names written in another script. */
    fun all(): List<ContactPhone> = emptyList()
}

interface AppCatalog {
    /** Apps that show in the launcher. */
    fun launchableApps(): List<InstalledApp>

    fun launchIntent(packageName: String): Intent?
}

interface ActivityStarter {
    fun hasPermission(permission: String): Boolean

    /** False when no installed app handles [intent]. */
    fun start(intent: Intent): Boolean
}
