package com.alesle.ai.agent.loop

import com.alesle.ai.agent.action.Choice
import com.alesle.ai.agent.loop.VoiceAnswers.YesNo
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class VoiceAnswersTest {
    @Test
    fun `short yes and no in three languages`() {
        listOf("Ha", "ha, yubor", "Mayli", "да", "Давай!", "yes", "OK", "go ahead").forEach {
            assertEquals(it, YesNo.YES, VoiceAnswers.yesNo(it))
        }
        listOf("Yo'q", "yo‘q", "kerak emas", "нет", "не надо", "no", "Cancel").forEach {
            assertEquals(it, YesNo.NO, VoiceAnswers.yesNo(it))
        }
    }

    @Test
    fun `a sentence, a mixed answer or silence is not an answer`() {
        assertNull(VoiceAnswers.yesNo("ha aytgancha onamga ham yozib qo'y iltimos"))
        assertNull(VoiceAnswers.yesNo("ha yo'q"))
        assertNull(VoiceAnswers.yesNo("  "))
        assertNull(VoiceAnswers.yesNo("hayot"))
    }

    private val choices =
        listOf(
            Choice("c1", "Aziz Karimov"),
            Choice("c2", "Aziz"),
            Choice("c3", "Dilshod Ish"),
        )

    @Test
    fun `picks a choice by name or place`() {
        assertEquals("c1", VoiceAnswers.pick("Aziz Karimovga", choices)?.ref)
        assertEquals("c3", VoiceAnswers.pick("dilshod", choices)?.ref)
        assertEquals("c2", VoiceAnswers.pick("ikkinchisi", choices)?.ref)
        assertEquals("c3", VoiceAnswers.pick("третий", choices)?.ref)
        assertEquals("c1", VoiceAnswers.pick("the first one", choices)?.ref)
    }

    @Test
    fun `nothing or more than one fits is no pick`() {
        assertNull(VoiceAnswers.pick("Onamga", choices))
        assertNull(VoiceAnswers.pick("", choices))
        assertNull(VoiceAnswers.pick("beshinchi", choices))
        assertNull(VoiceAnswers.pick("Ali", listOf(Choice("a", "Ali Vali"), Choice("b", "Ali Sami"))))
    }
}
