package com.alesle.ai.agent.loop

import com.alesle.ai.agent.action.AgentAction
import com.alesle.ai.agent.action.Target
import com.alesle.ai.agent.intent.IntentAction
import com.alesle.ai.agent.intent.Recipient
import com.alesle.ai.agent.protocol.DecodedAction
import com.alesle.ai.agent.snapshot.Bounds
import com.alesle.ai.agent.snapshot.CapturedScreen
import java.util.Locale

/** What the phone itself requires before an action, whatever the server said. */
sealed interface SafetyVerdict {
    data object Allow : SafetyVerdict

    data class Confirm(
        val confirmation: Confirmation,
    ) : SafetyVerdict

    data class Block(
        val reason: String,
    ) : SafetyVerdict
}

/**
 * Rules the model cannot switch off (security review, MASVS-PLATFORM): text
 * on a screen can talk the model into anything (prompt injection), so
 * calls, sends, payments and deletions are confirmed by the user on the
 * phone, with the sheet built from the action itself, not from the model's
 * words; USSD codes are never dialled; Alesle never operates itself.
 */
object SafetyPolicy {
    const val OWN_PACKAGE = "com.alesle.ai"

    /** A dialable number: digits with + ( ) - and spaces, 3–20 digits. No * or # (USSD). */
    private val PHONE = Regex("""^\+?[0-9 ()\-]{3,24}$""")

    /**
     * Action words, matched as whole words on short button labels only, so
     * navigation ("Call history", "Payments", "Sent") is not mistaken for the
     * action itself. No inline flags: Android's regex engine (ICU) rejects
     * some the JVM takes; labels are lower-cased first instead.
     */
    private fun words(vararg alternatives: String) = Regex("""(^|[^\p{L}'‘’])(${alternatives.joinToString("|")})($|[^\p{L}'‘’])""")

    private val SEND = words("send", "отправить", "отправ[иь]ть", "yuborish", "yubor", "post", "опубликовать")
    private val CALL = words("call", "voice call", "video call", "позвонить", "звонок", "qo['‘’]ng['‘’]iroq qilish", "qo['‘’]ng['‘’]iroq")
    private val PAY =
        words(
            "pay",
            "pay now",
            "оплатить",
            "to['‘’]lash",
            "buy",
            "купить",
            "sotib olish",
            "purchase",
            "checkout",
            "transfer",
            "перевести",
            "o['‘’]tkazish",
        )
    private val DELETE = words("delete", "удалить", "o['‘’]chirish", "remove")

    /** A button, not a row of text: a few words at most. */
    private const val MAX_ACTION_WORDS = 4

    /** Words that make a label a place to go, not the action ("Call history", "Payment methods"). */
    private val NAVIGATION =
        words(
            "history",
            "log",
            "logs",
            "settings",
            "methods",
            "recents",
            "list",
            "история",
            "журнал",
            "настройки",
            "способы",
            "tarixi",
            "tarix",
            "sozlamalar",
            "usullari",
        )

    fun isDialable(number: String): Boolean = PHONE.matches(number.trim()) && number.count(Char::isDigit) in 3..20

    fun check(
        action: DecodedAction,
        screen: CapturedScreen?,
        locale: String,
    ): SafetyVerdict {
        val words = Words.forLocale(locale)
        return when (action) {
            is DecodedAction.Intent -> checkIntent(action.action, words)
            is DecodedAction.Screen -> checkScreen(action.action, screen, words)
            is DecodedAction.WaitForUser -> SafetyVerdict.Allow
        }
    }

    private fun checkIntent(
        action: IntentAction,
        words: Words,
    ): SafetyVerdict =
        when (action) {
            is IntentAction.Call ->
                when (val to = action.to) {
                    is Recipient.Phone ->
                        if (!isDialable(to.number)) {
                            SafetyVerdict.Block("unsafe_number")
                        } else {
                            // A number the user never named: always ask.
                            SafetyVerdict.Confirm(Confirmation(words.call, to.number.trim(), always = true))
                        }
                    is Recipient.ContactName -> SafetyVerdict.Confirm(Confirmation(words.call, to.name, always = false))
                    is Recipient.ContactRef -> SafetyVerdict.Confirm(Confirmation(words.call, "", always = false))
                }
            is IntentAction.LaunchApp ->
                if (action.packageName == OWN_PACKAGE || action.appName?.trim()?.lowercase(Locale.ROOT) == "alesle") {
                    SafetyVerdict.Block("own_app")
                } else {
                    SafetyVerdict.Allow
                }
            else -> SafetyVerdict.Allow
        }

    private fun checkScreen(
        action: AgentAction,
        screen: CapturedScreen?,
        words: Words,
    ): SafetyVerdict {
        val target =
            when (action) {
                is AgentAction.Tap -> action.target
                is AgentAction.LongPress -> action.target
                else -> return SafetyVerdict.Allow
            }
        if (screen?.snapshot?.packageName == OWN_PACKAGE) return SafetyVerdict.Block("own_app")
        val label = labelAt(target, screen) ?: return SafetyVerdict.Allow
        val lower = label.lowercase(Locale.ROOT)
        if (lower.split(Regex("\\s+")).size > MAX_ACTION_WORDS || NAVIGATION.containsMatchIn(lower)) {
            return SafetyVerdict.Allow
        }
        val title =
            when {
                PAY.containsMatchIn(lower) -> return SafetyVerdict.Confirm(Confirmation(words.pay, label, always = true))
                DELETE.containsMatchIn(lower) -> return SafetyVerdict.Confirm(Confirmation(words.delete, label, always = true))
                SEND.containsMatchIn(lower) -> words.send
                CALL.containsMatchIn(lower) -> words.call
                else -> return SafetyVerdict.Allow
            }
        return SafetyVerdict.Confirm(Confirmation(title, label, always = false))
    }

    /** The words on what the tap lands on: the node and anything drawn inside it. */
    internal fun labelAt(
        target: Target,
        screen: CapturedScreen?,
    ): String? {
        if (screen == null) return null
        val area: Bounds =
            when (target) {
                is Target.Node -> screen.node(target.id)?.bounds ?: return null
                is Target.Point -> {
                    val x = screen.screen.left + (target.x * (screen.screen.right - screen.screen.left)).toInt()
                    val y = screen.screen.top + (target.y * (screen.screen.bottom - screen.screen.top)).toInt()
                    screen.nodes
                        .filter { it.bounds.left <= x && x < it.bounds.right && it.bounds.top <= y && y < it.bounds.bottom }
                        .minByOrNull { (it.bounds.right - it.bounds.left).toLong() * (it.bounds.bottom - it.bounds.top) }
                        ?.bounds ?: return null
                }
            }
        val parts =
            screen.nodes
                .filter {
                    it.bounds.left >= area.left &&
                        it.bounds.right <= area.right &&
                        it.bounds.top >= area.top &&
                        it.bounds.bottom <= area.bottom
                }.flatMap { listOfNotNull(it.text, it.contentDescription) }
                .map(String::trim)
                .filter(String::isNotEmpty)
                .distinct()
        return parts.joinToString(" ").take(MAX_LABEL).ifEmpty { null }
    }

    private const val MAX_LABEL = 80

    /** Sheet titles in the command's language. */
    private data class Words(
        val call: String,
        val send: String,
        val pay: String,
        val delete: String,
    ) {
        companion object {
            fun forLocale(locale: String): Words =
                when (locale.lowercase(Locale.ROOT).substringBefore('-')) {
                    "uz" -> Words("Qo‘ng‘iroq qilinsinmi?", "Yuborilsinmi?", "To‘lansinmi?", "O‘chirilsinmi?")
                    "ru" -> Words("Позвонить?", "Отправить?", "Оплатить?", "Удалить?")
                    else -> Words("Call?", "Send?", "Pay?", "Delete?")
                }
        }
    }
}
