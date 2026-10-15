package com.alesle.ai.agent.overlay

import android.app.Application
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.TextView
import androidx.test.core.app.ApplicationProvider
import com.alesle.ai.agent.action.Choice
import com.alesle.ai.agent.loop.Confirmation
import io.mockk.every
import io.mockk.mockk
import io.mockk.slot
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.time.Duration

@RunWith(RobolectricTestRunner::class)
@Config(qualifiers = "uz")
class AgentOverlayTest {
    private val context = ApplicationProvider.getApplicationContext<Application>()
    private val windows = mutableListOf<Pair<View, WindowManager.LayoutParams>>()
    private val windowManager =
        mockk<WindowManager>(relaxed = true).also { wm ->
            val view = slot<View>()
            val params = slot<ViewGroup.LayoutParams>()
            every { wm.addView(capture(view), capture(params)) } answers
                { windows += view.captured to (params.captured as WindowManager.LayoutParams) }
            every { wm.removeViewImmediate(any()) } answers { windows.removeAll { it.first === firstArg<View>() } }
        }
    private var stops = 0
    private val overlay =
        AgentOverlay(context, onStop = { stops++ }, windowManager = windowManager, main = Handler(Looper.getMainLooper()), sleepFor = {})

    private fun idle() = shadowOf(Looper.getMainLooper()).idle()

    private fun texts(view: View): List<String> =
        when (view) {
            is TextView -> listOf(view.text.toString())
            is ViewGroup -> (0 until view.childCount).flatMap { texts(view.getChildAt(it)) }
            else -> emptyList()
        }

    private fun find(
        view: View,
        text: String,
    ): View? {
        if (view is TextView && view.text.toString() == text) return view
        if (view is ViewGroup) {
            for (i in 0 until view.childCount) find(view.getChildAt(i), text)?.let { return it }
        }
        if (view.contentDescription?.toString() == text) return view
        return null
    }

    /** Clicks the nearest clickable view around [text], as a finger would. */
    private fun clickText(text: String) {
        var view: View? = windows.firstNotNullOf { find(it.first, text) }
        while (view != null && !view.hasOnClickListeners()) view = view.parent as? View
        checkNotNull(view) { "nothing clickable around $text" }.performClick()
        idle()
    }

    @Test
    fun `shows the glow and a pill with the step and STOP`() {
        overlay.showStep("Telegram ochilmoqda")
        idle()
        assertEquals(2, windows.size)
        windows.forEach { (_, params) -> assertEquals(WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY, params.type) }
        val glow = windows[0].second
        assertTrue("glow lets touches through", glow.flags and WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE != 0)
        assertTrue(texts(windows[1].first).contains("Telegram ochilmoqda"))

        overlay.showStep("Onam chati")
        idle()
        assertEquals(2, windows.size)
        assertTrue(texts(windows[1].first).contains("Onam chati"))

        clickText("To'xtatish")
        assertEquals(1, stops)
    }

    @Test
    fun `asks for confirmation and answers once`() {
        val answers = mutableListOf<Boolean>()
        overlay.confirm(Confirmation("Onamga yuborilsinmi?", "Kech qolaman", always = false), countdown = false) { answers += it }
        idle()
        val sheet = windows.single()
        assertTrue(sheet.second.flags and WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE == 0)
        assertTrue(texts(sheet.first).containsAll(listOf("Onamga yuborilsinmi?", "Kech qolaman", "Bekor qilish", "Tasdiqlash")))

        clickText("Tasdiqlash")
        assertEquals(listOf(true), answers)
        assertTrue(windows.isEmpty())
    }

    @Test
    fun `a cancelled confirmation answers no`() {
        val answers = mutableListOf<Boolean>()
        overlay.confirm(Confirmation("7:30 ga budilnik?", "", always = true), countdown = false) { answers += it }
        idle()
        assertTrue(texts(windows.single().first).contains("✓"))
        assertTrue("no empty detail chip", !texts(windows.single().first).contains(""))
        clickText("Bekor qilish")
        assertEquals(listOf(false), answers)
    }

    @Test
    fun `a countdown goes ahead after three seconds unless cancelled`() {
        val answers = mutableListOf<Boolean>()
        overlay.confirm(Confirmation("Budilnik", "7:30", always = false), countdown = true) { answers += it }
        idle()
        assertTrue(texts(windows.single().first).contains("3 soniyadan keyin bajariladi"))
        assertTrue("no digit badge for a time", texts(windows.single().first).contains("B"))
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofSeconds(1))
        assertTrue(texts(windows.single().first).contains("2 soniyadan keyin bajariladi"))
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofSeconds(2))
        assertEquals(listOf(true), answers)
        assertTrue(windows.isEmpty())

        overlay.confirm(Confirmation("Budilnik", "7:30", always = false), countdown = true) { answers += it }
        idle()
        clickText("Bekor qilish")
        shadowOf(Looper.getMainLooper()).idleFor(Duration.ofSeconds(5))
        assertEquals(listOf(true, false), answers)
    }

    @Test
    fun `asks which one and answers with the choice or null`() {
        val answers = mutableListOf<String?>()
        overlay.ask("Qaysi Aziz?", listOf(Choice("contact:1", "Aziz Karimov ··4567"), Choice("contact:2", "Aziz Work ··0012"))) {
            answers +=
                it
        }
        idle()
        assertTrue(texts(windows.single().first).containsAll(listOf("Qaysi Aziz?", "Aziz Karimov ··4567", "Aziz Work ··0012")))
        clickText("Aziz Work ··0012")
        assertEquals(listOf<String?>("contact:2"), answers)

        overlay.ask("Qaysi?", listOf(Choice("a", "A"))) { answers += it }
        idle()
        clickText("Bekor qilish")
        assertEquals(listOf("contact:2", null), answers)
    }

    @Test
    fun `hides its windows while a screenshot is taken, then shows them again`() {
        overlay.showStep("Ishlayapman")
        idle()
        val seen = mutableListOf<List<Int>>()
        val worker =
            Thread {
                overlay.concealed { seen += windows.map { it.first.visibility } }
            }
        worker.start()
        // The worker waits for the main thread to hide the windows.
        while (worker.isAlive) {
            idle()
            Thread.sleep(5)
        }
        idle()
        assertEquals(listOf(listOf(View.INVISIBLE, View.INVISIBLE)), seen)
        assertTrue(windows.all { it.first.visibility == View.VISIBLE })
    }

    @Test
    fun `on the main thread it captures without hiding`() {
        overlay.showStep("Ishlayapman")
        idle()
        assertEquals(View.VISIBLE, overlay.concealed { windows.first().first.visibility })
    }

    @Test
    fun `a new sheet replaces the old one, and hide removes everything`() {
        overlay.showStep("Ishlayapman")
        overlay.ask("Birinchi?", listOf(Choice("a", "A"))) {}
        overlay.ask("Ikkinchi?", listOf(Choice("b", "B"))) {}
        idle()
        assertEquals(3, windows.size)
        assertNull(windows.firstNotNullOfOrNull { find(it.first, "Birinchi?") })

        overlay.hide()
        idle()
        assertTrue(windows.isEmpty())
        overlay.hide()
        idle()
    }
}
