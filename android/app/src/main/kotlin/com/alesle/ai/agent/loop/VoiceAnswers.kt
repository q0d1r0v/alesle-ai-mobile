package com.alesle.ai.agent.loop

import com.alesle.ai.agent.action.Choice
import java.util.Locale

/**
 * Reads a spoken answer to the sheet on screen (hands-free): "ha" / "yo'q"
 * to a confirmation, or a choice by its name or place ("ikkinchisi").
 * Uzbek, Russian and English. Anything it cannot read with confidence is
 * null, and the words go to the agent as a change to the task instead.
 */
object VoiceAnswers {
    enum class YesNo { YES, NO }

    private val YES =
        setOf(
            "ha",
            "xa",
            "mayli",
            "albatta",
            "roziman",
            "tasdiqlayman",
            "boladi",
            "bo'ladi",
            "qil",
            "yubor",
            "qo'ng'iroq qil",
            "да",
            "давай",
            "конечно",
            "подтверждаю",
            "хорошо",
            "можно",
            "звони",
            "отправляй",
            "yes",
            "yeah",
            "yep",
            "sure",
            "confirm",
            "go ahead",
            "do it",
            "ok",
            "okay",
            "ок",
            "okey",
        )

    private val NO =
        setOf(
            "yo'q",
            "yoq",
            "kerak emas",
            "kerakmas",
            "bekor",
            "bekor qil",
            "qilma",
            "to'xta",
            "нет",
            "не надо",
            "не нужно",
            "отмена",
            "отмени",
            "стоп",
            "no",
            "nope",
            "cancel",
            "don't",
            "stop",
        )

    /** Short answers only: a sentence that merely contains "ha" is not a yes. */
    private const val MAX_ANSWER_WORDS = 4

    private val ORDINALS =
        listOf(
            setOf("birinchi", "birinchisi", "первый", "первая", "первое", "первого", "first", "1"),
            setOf("ikkinchi", "ikkinchisi", "второй", "вторая", "второе", "второго", "second", "2"),
            setOf("uchinchi", "uchinchisi", "третий", "третья", "третье", "третьего", "third", "3"),
            setOf("to'rtinchi", "to'rtinchisi", "четвёртый", "четвертый", "четвёртая", "fourth", "4"),
            setOf("beshinchi", "beshinchisi", "пятый", "пятая", "fifth", "5"),
        )

    fun yesNo(text: String): YesNo? {
        val said = normalize(text)
        val words = said.split(' ').filter { it.isNotEmpty() }
        if (words.isEmpty() || words.size > MAX_ANSWER_WORDS) return null
        val yes = YES.any { has(said, words, it) }
        val no = NO.any { has(said, words, it) }
        return when {
            yes && !no -> YesNo.YES
            no && !yes -> YesNo.NO
            else -> null
        }
    }

    /** The one choice [text] names; null when none or more than one fit. */
    fun pick(
        text: String,
        choices: List<Choice>,
    ): Choice? {
        val said = normalize(text)
        if (said.isEmpty()) return null
        val words = said.split(' ')
        ORDINALS.forEachIndexed { index, names ->
            if (index < choices.size && words.any { it in names }) return choices[index]
        }
        val named =
            choices.filter { choice ->
                val label = normalize(choice.label)
                label.isNotEmpty() && (said.contains(label) || (said.length >= MIN_PARTIAL && label.contains(said)))
            }
        if (named.size == 1) return named.single()
        // "Aziz Karimov" and "Aziz": the fullest name said wins, when it is the only one that long.
        val longest = named.maxByOrNull { normalize(it.label).length } ?: return null
        val ties = named.count { normalize(it.label).length == normalize(longest.label).length }
        return if (ties == 1 && said.contains(normalize(longest.label))) longest else null
    }

    private const val MIN_PARTIAL = 3

    private fun has(
        said: String,
        words: List<String>,
        phrase: String,
    ): Boolean = if (phrase.contains(' ')) said.contains(phrase) else phrase in words

    internal fun normalize(text: String): String =
        text
            .lowercase(Locale.ROOT)
            .replace('‘', '\'')
            .replace('’', '\'')
            .replace('ʻ', '\'')
            .replace('ʼ', '\'')
            .replace(Regex("[^\\p{L}\\p{N}' ]"), " ")
            .replace(Regex("\\s+"), " ")
            .trim()
}
