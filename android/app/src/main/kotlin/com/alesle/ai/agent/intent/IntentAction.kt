package com.alesle.ai.agent.intent

/**
 * System intents (SOW 03 §4): the cheapest and most reliable way to act,
 * because nothing on screen has to be read or tapped.
 */
sealed interface IntentAction {
    /** By [packageName], or by the name the user said ("Uzum Market"). */
    data class LaunchApp(
        val packageName: String? = null,
        val appName: String? = null,
    ) : IntentAction

    data class Call(
        val to: Recipient,
    ) : IntentAction

    /** Opens the messaging app with [text] filled in; sending is a confirmed UI tap. */
    data class Sms(
        val to: Recipient,
        val text: String,
    ) : IntentAction

    /** [days] are `java.util.Calendar` day constants for a repeating alarm. */
    data class Alarm(
        val hour: Int,
        val minute: Int,
        val label: String? = null,
        val days: List<Int> = emptyList(),
    ) : IntentAction

    /** Starts a countdown of [seconds] in the clock app, whatever its timer screen looks like. */
    data class Timer(
        val seconds: Int,
        val label: String? = null,
    ) : IntentAction

    /** Opens the calendar's new-event screen pre-filled; times are epoch millis. */
    data class CalendarEvent(
        val title: String,
        val beginMillis: Long,
        val endMillis: Long,
        val location: String? = null,
    ) : IntentAction

    data class WebSearch(
        val query: String,
    ) : IntentAction

    data class MapsSearch(
        val query: String,
    ) : IntentAction

    data class YouTubeSearch(
        val query: String,
    ) : IntentAction

    data class ShareText(
        val text: String,
        val packageName: String? = null,
    ) : IntentAction
}

/** Who a call or SMS goes to. */
sealed interface Recipient {
    data class Phone(
        val number: String,
    ) : Recipient

    /** A name to look up in the phone's contacts ("Onam", "Aziz"). */
    data class ContactName(
        val name: String,
    ) : Recipient

    /** A choice the user picked from an ambiguous lookup (`Choice.ref`). */
    data class ContactRef(
        val ref: String,
    ) : Recipient
}
