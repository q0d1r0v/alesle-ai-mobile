package com.alesle.ai.agent.intent

import android.Manifest
import android.app.SearchManager
import android.content.Intent
import android.net.Uri
import android.provider.AlarmClock
import android.provider.CalendarContract
import androidx.core.net.toUri
import com.alesle.ai.agent.action.ActionResult
import com.alesle.ai.agent.action.Choice
import java.text.Normalizer
import java.util.Locale

/**
 * Carries out an [IntentAction] (SOW 03 §4).
 *
 * Contacts and apps are looked up on the device. When a name fits several
 * entries the result is `ambiguous` with choices; the launcher never picks
 * one itself (AC-AG-5, EC-5). Only the name and the last digits of a number
 * leave the device, never the full number.
 */
class IntentLauncher(
    private val contacts: ContactsSource,
    private val apps: AppCatalog,
    private val starter: ActivityStarter,
) {
    fun execute(action: IntentAction): ActionResult =
        when (action) {
            is IntentAction.LaunchApp -> launchApp(action)
            is IntentAction.Call -> call(action)
            is IntentAction.Sms -> sms(action)
            is IntentAction.Alarm -> alarm(action)
            is IntentAction.CalendarEvent -> calendarEvent(action)
            is IntentAction.WebSearch -> webSearch(action.query)
            is IntentAction.MapsSearch -> mapsSearch(action.query)
            is IntentAction.YouTubeSearch -> youTubeSearch(action.query)
            is IntentAction.ShareText -> shareText(action)
        }

    private fun launchApp(action: IntentAction.LaunchApp): ActionResult {
        val packageName =
            action.packageName ?: run {
                val name = action.appName?.takeIf { it.isNotBlank() } ?: return ActionResult.error("app_not_specified")
                val matches = matchApps(name, apps.launchableApps())
                when (matches.size) {
                    0 -> return ActionResult.notFound("app_not_installed")
                    1 -> matches.single().packageName
                    else ->
                        return ActionResult.ambiguous(
                            "several_apps",
                            matches.take(MAX_CHOICES).map { Choice("app:${it.packageName}", it.label) },
                        )
                }
            }
        val intent = apps.launchIntent(packageName) ?: return ActionResult.notFound("app_not_installed")
        return start(intent)
    }

    private fun call(action: IntentAction.Call): ActionResult {
        val number =
            when (val resolved = resolve(action.to)) {
                is Resolved.Number -> resolved.number
                is Resolved.Failed -> return resolved.result
            }
        val uri = Uri.fromParts("tel", number, null)
        // Without CALL_PHONE the dialer opens with the number and the user presses call.
        val intent =
            if (starter.hasPermission(Manifest.permission.CALL_PHONE)) Intent(Intent.ACTION_CALL, uri) else Intent(Intent.ACTION_DIAL, uri)
        return start(intent)
    }

    private fun sms(action: IntentAction.Sms): ActionResult {
        val number =
            when (val resolved = resolve(action.to)) {
                is Resolved.Number -> resolved.number
                is Resolved.Failed -> return resolved.result
            }
        val intent = Intent(Intent.ACTION_SENDTO, Uri.fromParts("smsto", number, null)).putExtra("sms_body", action.text)
        return start(intent)
    }

    private fun alarm(action: IntentAction.Alarm): ActionResult {
        if (action.hour !in 0..23 || action.minute !in 0..59) return ActionResult.error("invalid_time")
        val intent =
            Intent(AlarmClock.ACTION_SET_ALARM)
                .putExtra(AlarmClock.EXTRA_HOUR, action.hour)
                .putExtra(AlarmClock.EXTRA_MINUTES, action.minute)
                .putExtra(AlarmClock.EXTRA_SKIP_UI, true)
        action.label?.let { intent.putExtra(AlarmClock.EXTRA_MESSAGE, it) }
        if (action.days.isNotEmpty()) intent.putIntegerArrayListExtra(AlarmClock.EXTRA_DAYS, ArrayList(action.days))
        return start(intent)
    }

    private fun calendarEvent(action: IntentAction.CalendarEvent): ActionResult {
        if (action.endMillis <= action.beginMillis) return ActionResult.error("invalid_time")
        val intent =
            Intent(Intent.ACTION_INSERT, CalendarContract.Events.CONTENT_URI)
                .putExtra(CalendarContract.Events.TITLE, action.title)
                .putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, action.beginMillis)
                .putExtra(CalendarContract.EXTRA_EVENT_END_TIME, action.endMillis)
        action.location?.let { intent.putExtra(CalendarContract.Events.EVENT_LOCATION, it) }
        return start(intent)
    }

    private fun webSearch(query: String): ActionResult {
        val search = Intent(Intent.ACTION_WEB_SEARCH).putExtra(SearchManager.QUERY, query)
        if (starter.start(search.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))) return ActionResult.OK
        return start(Intent(Intent.ACTION_VIEW, "https://www.google.com/search?q=${Uri.encode(query)}".toUri()))
    }

    private fun mapsSearch(query: String): ActionResult {
        val geo = "geo:0,0?q=${Uri.encode(query)}".toUri()
        // Google Earth can be the default geo: handler; "find on the map" means Maps when it is installed.
        if (starter.start(Intent(Intent.ACTION_VIEW, geo).setPackage(MAPS_PACKAGE).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))) {
            return ActionResult.OK
        }
        return start(Intent(Intent.ACTION_VIEW, geo))
    }

    private fun youTubeSearch(query: String): ActionResult {
        val app = Intent(Intent.ACTION_SEARCH).setPackage(YOUTUBE_PACKAGE).putExtra(SearchManager.QUERY, query)
        if (starter.start(app.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))) return ActionResult.OK
        return start(Intent(Intent.ACTION_VIEW, "https://www.youtube.com/results?search_query=${Uri.encode(query)}".toUri()))
    }

    private fun shareText(action: IntentAction.ShareText): ActionResult {
        val send = Intent(Intent.ACTION_SEND).setType("text/plain").putExtra(Intent.EXTRA_TEXT, action.text)
        val intent = if (action.packageName != null) send.setPackage(action.packageName) else Intent.createChooser(send, null)
        return start(intent)
    }

    private fun start(intent: Intent): ActionResult =
        if (starter.start(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))) {
            ActionResult.OK
        } else {
            ActionResult.notFound("no_app_for_intent")
        }

    private sealed interface Resolved {
        data class Number(
            val number: String,
        ) : Resolved

        data class Failed(
            val result: ActionResult,
        ) : Resolved
    }

    private fun resolve(recipient: Recipient): Resolved {
        if (recipient is Recipient.Phone) {
            return if (recipient.number.any(Char::isDigit)) {
                Resolved.Number(recipient.number)
            } else {
                Resolved.Failed(ActionResult.error("invalid_phone"))
            }
        }
        if (!starter.hasPermission(Manifest.permission.READ_CONTACTS)) {
            return Resolved.Failed(ActionResult.error("contacts_permission_missing"))
        }
        return when (recipient) {
            is Recipient.ContactRef -> {
                val id = recipient.ref.removePrefix(CONTACT_REF).toLongOrNull()
                val phone = id?.let(contacts::byId)
                if (phone == null) Resolved.Failed(ActionResult.notFound("contact_not_found")) else Resolved.Number(phone.number)
            }
            is Recipient.ContactName -> {
                // A name may come back as we showed it in a choice ("Aziz Ish ··0122",
                // remembered that way): the digits then pick among same-named contacts.
                val (name, tail) = splitChoiceLabel(recipient.name)
                val found = matchContacts(name, contacts.search(name))
                val matches =
                    if (tail == null) {
                        found
                    } else {
                        found.filter { it.number.filter(Char::isDigit).endsWith(tail) }.ifEmpty { found }
                    }
                when (matches.size) {
                    0 -> Resolved.Failed(ActionResult.notFound("contact_not_found"))
                    1 -> Resolved.Number(matches.single().number)
                    else ->
                        Resolved.Failed(
                            ActionResult.ambiguous("several_contacts", matches.take(MAX_CHOICES).map(::contactChoice)),
                        )
                }
            }
            is Recipient.Phone -> error("handled above")
        }
    }

    companion object {
        const val MAX_CHOICES = 5
        const val YOUTUBE_PACKAGE = "com.google.android.youtube"
        const val MAPS_PACKAGE = "com.google.android.apps.maps"
        private const val CONTACT_REF = "contact:"

        /** Lower-case, no accents or apostrophes, single spaces: "O'zbek  Telekom" == "ozbek telekom". */
        internal fun normalize(value: String): String =
            Normalizer
                .normalize(value, Normalizer.Form.NFD)
                .replace(Regex("\\p{M}+"), "")
                .replace(Regex("['ʻʼ‘’`]"), "")
                .lowercase(Locale.ROOT)
                .replace(Regex("\\s+"), " ")
                .trim()

        /**
         * Exact name matches win; otherwise any contact whose name contains the
         * query. One person with the same number twice counts once.
         */
        internal fun matchContacts(
            query: String,
            phones: List<ContactPhone>,
        ): List<ContactPhone> {
            val wanted = normalize(query)
            if (wanted.isEmpty()) return emptyList()
            val exact = phones.filter { normalize(it.name) == wanted }
            val candidates = exact.ifEmpty { phones.filter { normalize(it.name).contains(wanted) } }
            return candidates.distinctBy { it.number.filter(Char::isDigit) }
        }

        /** Exact label, then label prefix, then label containing the query, then the package name itself. */
        internal fun matchApps(
            query: String,
            installed: List<InstalledApp>,
        ): List<InstalledApp> {
            val wanted = normalize(query)
            if (wanted.isEmpty()) return emptyList()
            installed.filter { it.packageName == query.trim() }.let { if (it.isNotEmpty()) return it }
            val byLabel = installed.map { it to normalize(it.label) }
            val tiers =
                listOf<(String) -> Boolean>(
                    { it == wanted },
                    { it.startsWith(wanted) },
                    { it.contains(wanted) },
                )
            for (tier in tiers) {
                val hits = byLabel.filter { (_, label) -> tier(label) }.map { it.first }.distinctBy { it.packageName }
                if (hits.isNotEmpty()) return hits
            }
            return emptyList()
        }

        private val CHOICE_LABEL = Regex("""^(.*?)\s*··(\d{2,4})$""")

        /** "Aziz Ish ··0122" -> ("Aziz Ish", "0122"); any other name -> (name, null). */
        internal fun splitChoiceLabel(label: String): Pair<String, String?> {
            val match = CHOICE_LABEL.matchEntire(label.trim()) ?: return label.trim() to null
            return match.groupValues[1].trim() to match.groupValues[2]
        }

        /** "Aziz Karimov ··4567": enough to tell two people apart, without the full number. */
        internal fun contactChoice(phone: ContactPhone): Choice {
            val digits = phone.number.filter(Char::isDigit)
            return Choice("$CONTACT_REF${phone.id}", "${phone.name} ··${digits.takeLast(4)}")
        }
    }
}
