package com.alesle.ai.agent.intent

import android.Manifest
import android.app.SearchManager
import android.content.Intent
import android.net.Uri
import android.provider.AlarmClock
import android.provider.CalendarContract
import com.alesle.ai.agent.action.ActionResult
import com.alesle.ai.agent.action.ActionStatus
import com.alesle.ai.agent.action.Choice
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.util.Calendar

@RunWith(RobolectricTestRunner::class)
class IntentLauncherTest {
    private val contacts = FakeContacts()
    private val apps = FakeApps()
    private val starter = FakeStarter()
    private val launcher = IntentLauncher(contacts, apps, starter)

    private val started: Intent get() = starter.started.last()

    // --- launch app ---

    @Test
    fun `launches an app by package`() {
        apps.installed += InstalledApp("Telegram", "org.telegram.messenger")
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.LaunchApp(packageName = "org.telegram.messenger")))
        assertEquals("org.telegram.messenger", started.`package`)
        assertTrue(started.flags and Intent.FLAG_ACTIVITY_NEW_TASK != 0)
    }

    @Test
    fun `launches an app by the name the user said`() {
        apps.installed += listOf(InstalledApp("Uzum Market", "uz.uzum.app"), InstalledApp("Telegram", "org.telegram.messenger"))
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.LaunchApp(appName = "uzum market")))
        assertEquals("uz.uzum.app", started.`package`)
    }

    @Test
    fun `asks when several apps fit the name`() {
        apps.installed += listOf(InstalledApp("Yandex Go", "ru.yandex.taxi"), InstalledApp("Yandex Maps", "ru.yandex.yandexmaps"))
        val result = launcher.execute(IntentAction.LaunchApp(appName = "Yandex"))
        assertEquals(ActionStatus.AMBIGUOUS, result.status)
        assertEquals(
            listOf(Choice("app:ru.yandex.taxi", "Yandex Go"), Choice("app:ru.yandex.yandexmaps", "Yandex Maps")),
            result.choices,
        )
        assertTrue(starter.started.isEmpty())
    }

    @Test
    fun `reports a missing or unnamed app`() {
        assertEquals(ActionResult.notFound("app_not_installed"), launcher.execute(IntentAction.LaunchApp(appName = "Uzum")))
        assertEquals(ActionResult.notFound("app_not_installed"), launcher.execute(IntentAction.LaunchApp(packageName = "x.y")))
        assertEquals(ActionResult.error("app_not_specified"), launcher.execute(IntentAction.LaunchApp(appName = " ")))
        assertEquals(ActionResult.error("app_not_specified"), launcher.execute(IntentAction.LaunchApp()))
    }

    @Test
    fun `matches app names forgivingly, preferring the closest`() {
        val installed =
            listOf(
                InstalledApp("O‘zbekiston Temir Yo‘llari", "uz.railway"),
                InstalledApp("Maps", "com.google.android.apps.maps"),
                InstalledApp("Yandex Maps", "ru.yandex.yandexmaps"),
                InstalledApp("Click", "air.com.ssdsoftwaresolutions.clickuz"),
            )
        assertEquals(listOf("uz.railway"), IntentLauncher.matchApps("ozbekiston temir", installed).map { it.packageName })
        assertEquals(listOf("com.google.android.apps.maps"), IntentLauncher.matchApps("Maps", installed).map { it.packageName })
        assertEquals(listOf("ru.yandex.yandexmaps"), IntentLauncher.matchApps("yandex", installed).map { it.packageName })
        assertEquals(listOf("ru.yandex.yandexmaps"), IntentLauncher.matchApps("ru.yandex.yandexmaps", installed).map { it.packageName })
        assertEquals(emptyList<InstalledApp>(), IntentLauncher.matchApps("payme", installed))
        assertEquals(emptyList<InstalledApp>(), IntentLauncher.matchApps("  ", installed))
    }

    // --- call ---

    @Test
    fun `calls a number directly when allowed, else opens the dialer`() {
        starter.granted += Manifest.permission.CALL_PHONE
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.Call(Recipient.Phone("+998901234567"))))
        assertEquals(Intent.ACTION_CALL, started.action)
        assertEquals(Uri.fromParts("tel", "+998901234567", null), started.data)

        starter.granted.clear()
        launcher.execute(IntentAction.Call(Recipient.Phone("+998901234567")))
        assertEquals(Intent.ACTION_DIAL, started.action)
    }

    @Test
    fun `calls the one contact that fits the name`() {
        starter.granted += Manifest.permission.READ_CONTACTS
        contacts.phones += listOf(ContactPhone(1, "Onam", "+998 90 111 22 33"), ContactPhone(2, "Dadam", "+998901112244"))
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.Call(Recipient.ContactName("onam"))))
        assertEquals(Uri.fromParts("tel", "+998 90 111 22 33", null), started.data)
    }

    @Test
    fun `asks which contact when two share a name, showing only the last digits`() {
        starter.granted += Manifest.permission.READ_CONTACTS
        contacts.phones += listOf(ContactPhone(7, "Aziz", "+998901234567"), ContactPhone(9, "Aziz", "+998935557788"))
        val result = launcher.execute(IntentAction.Call(Recipient.ContactName("Aziz")))
        assertEquals(ActionStatus.AMBIGUOUS, result.status)
        assertEquals("several_contacts", result.reason)
        assertEquals(listOf(Choice("contact:7", "Aziz ··4567"), Choice("contact:9", "Aziz ··7788")), result.choices)
        assertTrue(starter.started.isEmpty())
    }

    @Test
    fun `a name given as a choice label reaches that contact by its last digits`() {
        starter.granted += Manifest.permission.READ_CONTACTS
        contacts.phones += listOf(ContactPhone(7, "Aziz", "+998901234567"), ContactPhone(9, "Aziz", "+998935557788"))
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.Call(Recipient.ContactName("Aziz ··7788"))))
        assertEquals(Uri.fromParts("tel", "+998935557788", null), started.data)
        // Digits that fit nobody: back to asking.
        val unknown = launcher.execute(IntentAction.Call(Recipient.ContactName("Aziz ··0000")))
        assertEquals(ActionStatus.AMBIGUOUS, unknown.status)
    }

    @Test
    fun `splits choice labels`() {
        assertEquals("Aziz Ish" to "0122", IntentLauncher.splitChoiceLabel(" Aziz Ish ··0122 "))
        assertEquals("Onam" to null, IntentLauncher.splitChoiceLabel("Onam"))
        assertEquals("Ona ··x" to null, IntentLauncher.splitChoiceLabel("Ona ··x"))
    }

    @Test
    fun `calls the contact the user picked`() {
        starter.granted += Manifest.permission.READ_CONTACTS
        contacts.phones += ContactPhone(9, "Aziz", "+998935557788")
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.Call(Recipient.ContactRef("contact:9"))))
        assertEquals(Uri.fromParts("tel", "+998935557788", null), started.data)

        assertEquals(
            ActionResult.notFound("contact_not_found"),
            launcher.execute(IntentAction.Call(Recipient.ContactRef("contact:404"))),
        )
        assertEquals(
            ActionResult.notFound("contact_not_found"),
            launcher.execute(IntentAction.Call(Recipient.ContactRef("garbage"))),
        )
    }

    @Test
    fun `explains why it cannot call`() {
        assertEquals(
            ActionResult.error("contacts_permission_missing"),
            launcher.execute(IntentAction.Call(Recipient.ContactName("Onam"))),
        )
        starter.granted += Manifest.permission.READ_CONTACTS
        assertEquals(ActionResult.notFound("contact_not_found"), launcher.execute(IntentAction.Call(Recipient.ContactName("Onam"))))
        assertEquals(ActionResult.error("invalid_phone"), launcher.execute(IntentAction.Call(Recipient.Phone("mama"))))
        assertTrue(starter.started.isEmpty())
    }

    @Test
    fun `finds a contact whose name is saved in the other script`() {
        starter.granted += Manifest.permission.READ_CONTACTS
        contacts.phones += listOf(ContactPhone(1, "Eval Tester", "+15550100"), ContactPhone(2, "Дилшод Иш", "+998901112244"))
        // Heard in Russian, saved in Latin, one vowel off: still that person.
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.Call(Recipient.ContactName("Эвел Тестер"))))
        assertEquals(Uri.fromParts("tel", "+15550100", null), started.data)
        // Heard in Latin, saved in Cyrillic.
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.Call(Recipient.ContactName("Dilshod Ish"))))
        assertEquals(Uri.fromParts("tel", "+998901112244", null), started.data)
        assertEquals(
            ActionResult.notFound("contact_not_found"),
            launcher.execute(IntentAction.Call(Recipient.ContactName("Бобур"))),
        )
        // The confirmation names who the call reaches.
        assertEquals("Eval Tester ··0100", launcher.recipientLabel(Recipient.ContactName("Эвел Тестер")))
        assertEquals("Дилшод Иш ··2244", launcher.recipientLabel(Recipient.ContactRef("contact:2")))
        assertEquals(null, launcher.recipientLabel(Recipient.ContactName("Бобур")))
        assertEquals(null, launcher.recipientLabel(Recipient.Phone("+998901112244")))
    }

    @Test
    fun `script-blind matching allows a slip, not a different name`() {
        val phones =
            listOf(
                ContactPhone(1, "Azizbek", "+1"),
                ContactPhone(2, "Ali", "+2"),
                ContactPhone(3, "Ғайрат Қодиров", "+3"),
                ContactPhone(4, "Ёрқин", "+4"),
            )
        assertEquals(listOf(1L), IntentLauncher.matchAcrossScripts("Азизбек", phones).map { it.id })
        assertEquals(listOf(3L), IntentLauncher.matchAcrossScripts("G'ayrat Qodirov", phones).map { it.id })
        assertEquals(listOf(4L), IntentLauncher.matchAcrossScripts("Yorqin", phones).map { it.id })
        // Short names must match exactly: "Ola" is not "Ali".
        assertEquals(emptyList<Long>(), IntentLauncher.matchAcrossScripts("Ola", phones).map { it.id })
        assertEquals(emptyList<Long>(), IntentLauncher.matchAcrossScripts("  ", phones).map { it.id })
        assertEquals("eval tester", IntentLauncher.latin("Eval  Tester"))
        assertEquals("sherzod", IntentLauncher.latin("Шерзод"))
        assertEquals(3, IntentLauncher.editDistance("kitten", "sitting"))
    }

    @Test
    fun `matches contacts exactly first, then by part of the name, once per number`() {
        val phones =
            listOf(
                ContactPhone(1, "Aziz", "+998901234567"),
                ContactPhone(2, "Aziz aka", "+998935557788"),
                ContactPhone(3, "Aziz", "+998 90 123 45 67"),
            )
        assertEquals(listOf(1L), IntentLauncher.matchContacts("aziz", phones).map { it.id })
        assertEquals(listOf(2L), IntentLauncher.matchContacts("aka", phones).map { it.id })
        assertEquals(emptyList<ContactPhone>(), IntentLauncher.matchContacts(" ", phones))
    }

    // --- sms ---

    @Test
    fun `opens the messaging app with the text filled in`() {
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.Sms(Recipient.Phone("+998901234567"), "Kech qolaman")))
        assertEquals(Intent.ACTION_SENDTO, started.action)
        assertEquals(Uri.fromParts("smsto", "+998901234567", null), started.data)
        assertEquals("Kech qolaman", started.getStringExtra("sms_body"))
    }

    @Test
    fun `an ambiguous sms recipient is asked about, not guessed`() {
        starter.granted += Manifest.permission.READ_CONTACTS
        contacts.phones += listOf(ContactPhone(1, "Aziz", "+998901234567"), ContactPhone(2, "Aziz", "+998935557788"))
        assertEquals(ActionStatus.AMBIGUOUS, launcher.execute(IntentAction.Sms(Recipient.ContactName("Aziz"), "x")).status)
        assertTrue(starter.started.isEmpty())
    }

    // --- alarm / calendar ---

    @Test
    fun `sets an alarm without opening the clock UI`() {
        val action = IntentAction.Alarm(7, 30, label = "Ish", days = listOf(Calendar.MONDAY, Calendar.FRIDAY))
        assertEquals(ActionResult.OK, launcher.execute(action))
        assertEquals(AlarmClock.ACTION_SET_ALARM, started.action)
        assertEquals(7, started.getIntExtra(AlarmClock.EXTRA_HOUR, -1))
        assertEquals(30, started.getIntExtra(AlarmClock.EXTRA_MINUTES, -1))
        assertTrue(started.getBooleanExtra(AlarmClock.EXTRA_SKIP_UI, false))
        assertEquals("Ish", started.getStringExtra(AlarmClock.EXTRA_MESSAGE))
        assertEquals(listOf(Calendar.MONDAY, Calendar.FRIDAY), started.getIntegerArrayListExtra(AlarmClock.EXTRA_DAYS))
    }

    @Test
    fun `starts a timer in the clock app without its timer screen`() {
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.Timer(300, label = "Choy")))
        assertEquals(AlarmClock.ACTION_SET_TIMER, started.action)
        assertEquals(300, started.getIntExtra(AlarmClock.EXTRA_LENGTH, -1))
        assertTrue(started.getBooleanExtra(AlarmClock.EXTRA_SKIP_UI, false))
        assertEquals("Choy", started.getStringExtra(AlarmClock.EXTRA_MESSAGE))
        launcher.execute(IntentAction.Timer(60))
        assertFalse(started.hasExtra(AlarmClock.EXTRA_MESSAGE))
        val before = starter.started.size
        assertEquals(ActionResult.error("invalid_time"), launcher.execute(IntentAction.Timer(0)))
        assertEquals(ActionResult.error("invalid_time"), launcher.execute(IntentAction.Timer(86_401)))
        assertEquals(before, starter.started.size)
    }

    @Test
    fun `a one-off alarm carries no label or days`() {
        launcher.execute(IntentAction.Alarm(0, 0))
        assertFalse(started.hasExtra(AlarmClock.EXTRA_MESSAGE))
        assertFalse(started.hasExtra(AlarmClock.EXTRA_DAYS))
    }

    @Test
    fun `rejects an impossible time`() {
        assertEquals(ActionResult.error("invalid_time"), launcher.execute(IntentAction.Alarm(24, 0)))
        assertEquals(ActionResult.error("invalid_time"), launcher.execute(IntentAction.Alarm(7, 60)))
        assertEquals(ActionResult.error("invalid_time"), launcher.execute(IntentAction.CalendarEvent("x", 2_000, 1_000)))
        assertTrue(starter.started.isEmpty())
    }

    @Test
    fun `opens a pre-filled calendar event`() {
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.CalendarEvent("Uchrashuv", 1_000, 2_000, "Ofis")))
        assertEquals(Intent.ACTION_INSERT, started.action)
        assertEquals(CalendarContract.Events.CONTENT_URI, started.data)
        assertEquals("Uchrashuv", started.getStringExtra(CalendarContract.Events.TITLE))
        assertEquals(1_000L, started.getLongExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, 0))
        assertEquals(2_000L, started.getLongExtra(CalendarContract.EXTRA_EVENT_END_TIME, 0))
        assertEquals("Ofis", started.getStringExtra(CalendarContract.Events.EVENT_LOCATION))

        launcher.execute(IntentAction.CalendarEvent("Uchrashuv", 1_000, 2_000))
        assertNull(started.getStringExtra(CalendarContract.Events.EVENT_LOCATION))
    }

    // --- searches / share ---

    @Test
    fun `searches the web in the Google app, then any search app, then a browser`() {
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.WebSearch("ob-havo")))
        assertEquals(Intent.ACTION_WEB_SEARCH, started.action)
        assertEquals(IntentLauncher.GOOGLE_APP_PACKAGE, started.`package`)
        assertEquals("ob-havo", started.getStringExtra(SearchManager.QUERY))

        starter.refuse = { it.`package` == IntentLauncher.GOOGLE_APP_PACKAGE }
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.WebSearch("ob-havo")))
        assertEquals(Intent.ACTION_WEB_SEARCH, started.action)
        assertNull(started.`package`)

        starter.refuse = { it.action == Intent.ACTION_WEB_SEARCH }
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.WebSearch("ob havo")))
        assertEquals(Uri.parse("https://www.google.com/search?q=ob%20havo"), started.data)
    }

    @Test
    fun `searches Google Maps, falling back to any map app`() {
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.MapsSearch("eng yaqin dorixona")))
        assertEquals(Uri.parse("geo:0,0?q=eng%20yaqin%20dorixona"), started.data)
        assertEquals(IntentLauncher.MAPS_PACKAGE, started.`package`)

        starter.refuse = { it.`package` == IntentLauncher.MAPS_PACKAGE }
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.MapsSearch("Chorsu")))
        assertEquals(Uri.parse("geo:0,0?q=Chorsu"), started.data)
        assertNull(started.`package`)
    }

    @Test
    fun `searches YouTube in the app, falling back to the website`() {
        assertEquals(ActionResult.OK, launcher.execute(IntentAction.YouTubeSearch("Shoxrux")))
        assertEquals(IntentLauncher.YOUTUBE_PACKAGE, started.`package`)
        assertEquals("Shoxrux", started.getStringExtra(SearchManager.QUERY))

        starter.refuse = { it.`package` == IntentLauncher.YOUTUBE_PACKAGE }
        launcher.execute(IntentAction.YouTubeSearch("Shoxrux"))
        assertEquals(Uri.parse("https://www.youtube.com/results?search_query=Shoxrux"), started.data)
    }

    @Test
    fun `shares text to an app or through the chooser`() {
        launcher.execute(IntentAction.ShareText("Salom", packageName = "org.telegram.messenger"))
        assertEquals(Intent.ACTION_SEND, started.action)
        assertEquals("org.telegram.messenger", started.`package`)
        assertEquals("Salom", started.getStringExtra(Intent.EXTRA_TEXT))

        launcher.execute(IntentAction.ShareText("Salom"))
        assertEquals(Intent.ACTION_CHOOSER, started.action)
    }

    @Test
    fun `reports when no app handles the intent`() {
        starter.refuse = { true }
        assertEquals(ActionResult.notFound("no_app_for_intent"), launcher.execute(IntentAction.MapsSearch("x")))
        assertEquals(ActionResult.notFound("no_app_for_intent"), launcher.execute(IntentAction.WebSearch("x")))
    }

    @Test
    fun `normalises names for matching`() {
        assertEquals("ozbek telekom", IntentLauncher.normalize("  O'zbek   Telekom "))
        assertEquals("ozbekiston", IntentLauncher.normalize("O‘zbekiston"))
        assertEquals("cafe", IntentLauncher.normalize("Café"))
    }
}

private class FakeContacts : ContactsSource {
    val phones = mutableListOf<ContactPhone>()

    override fun search(query: String) = phones.filter { it.name.contains(query, ignoreCase = true) }

    override fun byId(id: Long) = phones.firstOrNull { it.id == id }

    override fun all() = phones
}

private class FakeApps : AppCatalog {
    val installed = mutableListOf<InstalledApp>()

    override fun launchableApps() = installed

    override fun launchIntent(packageName: String): Intent? =
        if (installed.any { it.packageName == packageName }) Intent(Intent.ACTION_MAIN).setPackage(packageName) else null
}

private class FakeStarter : ActivityStarter {
    val granted = mutableSetOf<String>()
    val started = mutableListOf<Intent>()
    var refuse: (Intent) -> Boolean = { false }

    override fun hasPermission(permission: String) = permission in granted

    override fun start(intent: Intent): Boolean {
        if (refuse(intent)) return false
        started += intent
        return true
    }
}
