package com.alesle.ai.agent.overlay

import android.annotation.SuppressLint
import android.content.Context
import android.content.res.Configuration
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.RectF
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.text.TextUtils
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import com.alesle.ai.R
import com.alesle.ai.agent.action.Choice
import com.alesle.ai.agent.loop.Confirmation
import com.alesle.ai.agent.loop.LoopUi
import java.util.Locale
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

/**
 * What the user sees while Alesle works in other apps (SOW 03 §8, design
 * "Working", "Send to Mom?", "Which Aziz?"): a violet edge glow, a pill with
 * the current step and STOP, and bottom sheets for confirmations and choices.
 *
 * Accessibility overlays need no extra permission and are not the active
 * window, so they never appear in the agent's own snapshots. Everything runs
 * on the main thread; the [LoopUi] calls may come from any thread.
 */
class AgentOverlay(
    context: Context,
    private val onStop: () -> Unit,
    /** The command's language (BCP-47): the sheets speak it, not the phone's. */
    locale: String? = null,
    private val windowManager: WindowManager = context.getSystemService(WindowManager::class.java),
    private val main: Handler = Handler(Looper.getMainLooper()),
    private val sleepFor: (Long) -> Unit = Thread::sleep,
) : LoopUi {
    private val context: Context = localized(context, locale)
    private val added = mutableSetOf<View>()
    private var glow: View? = null
    private var pill: View? = null
    private var pillText: TextView? = null
    private var sheet: View? = null
    private var countdown: Runnable? = null

    override fun showStep(say: String) {
        main.post {
            if (glow == null) glow = GlowView(context).also { add(it, fullScreen(touchable = false)) }
            val text = pillText
            if (text == null) buildPill(say) else text.text = say
        }
    }

    override fun confirm(
        confirmation: Confirmation,
        countdown: Boolean,
        answer: (approved: Boolean) -> Unit,
    ) {
        main.post { showConfirm(confirmation, countdown, once(answer)) }
    }

    override fun ask(
        question: String,
        choices: List<Choice>,
        answer: (ref: String?) -> Unit,
    ) {
        main.post { showAsk(question, choices, once(answer)) }
    }

    override fun <T> concealed(capture: () -> T): T {
        // Never block the main thread on itself.
        if (Looper.myLooper() == Looper.getMainLooper()) return capture()
        setVisibleAndWait(false)
        try {
            return capture()
        } finally {
            main.post { setVisible(true) }
        }
    }

    private fun setVisibleAndWait(visible: Boolean) {
        val applied = CountDownLatch(1)
        main.post {
            setVisible(visible)
            applied.countDown()
        }
        applied.await(CONCEAL_WAIT_MS, TimeUnit.MILLISECONDS)
        // One composited frame without our windows before the capture.
        sleepFor(CONCEAL_FRAME_MS)
    }

    private fun setVisible(visible: Boolean) {
        val state = if (visible) View.VISIBLE else View.INVISIBLE
        listOf(glow, pill, sheet).forEach { it?.visibility = state }
    }

    override fun hide() {
        main.post {
            closeSheet()
            listOf(glow, pill).forEach { it?.let(::remove) }
            glow = null
            pill = null
            pillText = null
        }
    }

    // ── Pill ────────────────────────────────────────────────────────────────

    private fun buildPill(say: String) {
        val row =
            LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dp(14), dp(10), dp(10), dp(10))
                background = rounded(Color.WHITE, dp(30).toFloat())
                elevation = dp(8).toFloat()
            }
        row.addView(SpinnerDot(context), LinearLayout.LayoutParams(dp(30), dp(30)))
        val text =
            label(say, sizeSp = 15f, bold = true, color = INK).apply {
                maxLines = 1
                ellipsize = TextUtils.TruncateAt.END
            }
        row.addView(text, LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply { marginStart = dp(12) })
        val stop =
            label("■  " + context.getString(R.string.overlay_stop), sizeSp = 14f, bold = true, color = Color.WHITE).apply {
                background = rounded(INK, dp(22).toFloat())
                setPadding(dp(16), dp(10), dp(16), dp(10))
                setOnClickListener { onStop() }
                contentDescription = context.getString(R.string.overlay_stop)
            }
        row.addView(stop)
        // The window spans the width; the card floats 8 dp from the edges like the design's glass sheet.
        val frame = FrameLayout(context).apply { setPadding(dp(8), 0, dp(8), 0) }
        frame.addView(row, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT))
        pill = frame
        pillText = text
        add(
            frame,
            params(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, focusable = false).apply {
                gravity = Gravity.TOP
                y = dp(TOP_INSET_DP)
            },
        )
    }

    // ── Sheets ──────────────────────────────────────────────────────────────

    private fun showConfirm(
        confirmation: Confirmation,
        countdown: Boolean,
        answer: (Boolean) -> Unit,
    ) {
        val card = sheetCard()
        card.addView(initialBadge(confirmation.title), centered(dp(56), dp(56)))
        card.addView(
            label(confirmation.title, sizeSp = 22f, bold = true, color = INK).apply { gravity = Gravity.CENTER },
            centered(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, top = 14),
        )
        if (confirmation.detail.isNotBlank()) {
            card.addView(
                label(confirmation.detail, sizeSp = 16f, bold = false, color = Color.WHITE).apply {
                    background = gradient(VIOLET_TOP, VIOLET_BOTTOM, dp(16).toFloat())
                    setPadding(dp(16), dp(10), dp(16), dp(10))
                    gravity = Gravity.CENTER
                },
                centered(ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT, top = 14),
            )
        }
        val buttons = LinearLayout(context).apply { orientation = LinearLayout.HORIZONTAL }
        val cancel = capsule(context.getString(R.string.overlay_cancel), filled = false) { finishSheet { answer(false) } }
        val ok = capsule(context.getString(R.string.overlay_confirm), filled = true) { finishSheet { answer(true) } }
        buttons.addView(cancel, LinearLayout.LayoutParams(0, dp(52), 1f))
        buttons.addView(ok, LinearLayout.LayoutParams(0, dp(52), 1f).apply { marginStart = dp(10) })
        card.addView(buttons, centered(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, top = 20))

        val note =
            if (countdown) {
                label("", sizeSp = 13f, bold = false, color = TEXT_2).apply { gravity = Gravity.CENTER }.also {
                    card.addView(it, centered(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, top = 12))
                }
            } else {
                null
            }
        // Open first: opening closes any previous sheet and its timer.
        openSheet(card)
        note?.let { startCountdown(it) { finishSheet { answer(true) } } }
    }

    private fun showAsk(
        question: String,
        choices: List<Choice>,
        answer: (String?) -> Unit,
    ) {
        val card = sheetCard()
        card.addView(
            label(question, sizeSp = 22f, bold = true, color = INK),
            centered(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT),
        )
        val list =
            LinearLayout(context).apply {
                orientation = LinearLayout.VERTICAL
                background = rounded(CANVAS, dp(20).toFloat())
            }
        choices.forEach { choice ->
            val row =
                LinearLayout(context).apply {
                    orientation = LinearLayout.HORIZONTAL
                    gravity = Gravity.CENTER_VERTICAL
                    setPadding(dp(12), dp(10), dp(14), dp(10))
                    setOnClickListener { finishSheet { answer(choice.ref) } }
                    contentDescription = choice.label
                }
            row.addView(initialBadge(choice.label), LinearLayout.LayoutParams(dp(40), dp(40)))
            row.addView(
                label(choice.label, sizeSp = 16f, bold = true, color = INK),
                LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f).apply { marginStart = dp(12) },
            )
            row.addView(label("›", sizeSp = 22f, bold = false, color = TEXT_2))
            list.addView(row)
        }
        card.addView(list, centered(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, top = 14))
        card.addView(
            capsule(context.getString(R.string.overlay_cancel), filled = false) { finishSheet { answer(null) } },
            centered(ViewGroup.LayoutParams.MATCH_PARENT, dp(52), top = 14),
        )
        openSheet(card)
    }

    private fun startCountdown(
        note: TextView,
        done: () -> Unit,
    ) {
        var left = COUNTDOWN_SECONDS
        val tick =
            object : Runnable {
                override fun run() {
                    if (left == 0) {
                        done()
                        return
                    }
                    note.text = context.resources.getQuantityString(R.plurals.overlay_countdown, left, left)
                    left--
                    main.postDelayed(this, SECOND_MS)
                }
            }
        countdown = tick
        tick.run()
    }

    private fun openSheet(card: LinearLayout) {
        closeSheet()
        // A dimmed backdrop takes the touches: the app below must not be tapped while we ask.
        val backdrop =
            FrameLayout(context).apply {
                setBackgroundColor(BACKDROP)
                isClickable = true
            }
        backdrop.addView(
            card,
            FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT, Gravity.BOTTOM).apply {
                setMargins(dp(8), 0, dp(8), dp(8))
            },
        )
        sheet = backdrop
        add(backdrop, fullScreen(touchable = true))
    }

    private fun finishSheet(then: () -> Unit) {
        closeSheet()
        then()
    }

    private fun closeSheet() {
        countdown?.let(main::removeCallbacks)
        countdown = null
        sheet?.let(::remove)
        sheet = null
    }

    // ── Building blocks (design tokens: alesle-ai-pages "Mobile MVP") ──────

    private fun sheetCard() =
        LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            gravity = Gravity.CENTER_HORIZONTAL
            setPadding(dp(18), dp(22), dp(18), dp(18))
            background = rounded(Color.WHITE, dp(34).toFloat())
            elevation = dp(12).toFloat()
        }

    private fun capsule(
        text: String,
        filled: Boolean,
        onClick: () -> Unit,
    ) = label(text, sizeSp = 16f, bold = true, color = if (filled) Color.WHITE else INK).apply {
        gravity = Gravity.CENTER
        background = rounded(if (filled) INK else CAPSULE_GREY, dp(26).toFloat())
        setOnClickListener { onClick() }
    }

    private fun initialBadge(name: String) =
        // A person's initial, as in the design; a check mark when the title starts with a digit or symbol ("7:30 …").
        label(
            name
                .trim()
                .firstOrNull()
                ?.takeIf(Char::isLetter)
                ?.uppercase() ?: "✓",
            sizeSp = 18f,
            bold = true,
            color = Color.WHITE,
        ).apply {
            gravity = Gravity.CENTER
            background =
                GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, intArrayOf(VIOLET_TOP, VIOLET_BOTTOM)).apply {
                    shape =
                        GradientDrawable.OVAL
                }
            importantForAccessibility = View.IMPORTANT_FOR_ACCESSIBILITY_NO
        }

    private fun label(
        text: String,
        sizeSp: Float,
        bold: Boolean,
        color: Int,
    ) = TextView(context).apply {
        this.text = text
        setTextSize(TypedValue.COMPLEX_UNIT_SP, sizeSp)
        setTextColor(color)
        typeface = Typeface.create(Typeface.SANS_SERIF, if (bold) Typeface.BOLD else Typeface.NORMAL)
    }

    private fun rounded(
        color: Int,
        radius: Float,
    ) = GradientDrawable().apply {
        setColor(color)
        cornerRadius = radius
    }

    private fun gradient(
        top: Int,
        bottom: Int,
        radius: Float,
    ) = GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM, intArrayOf(top, bottom)).apply { cornerRadius = radius }

    private fun centered(
        width: Int,
        height: Int,
        top: Int = 0,
    ) = LinearLayout.LayoutParams(width, height).apply {
        gravity = Gravity.CENTER_HORIZONTAL
        topMargin = dp(top)
    }

    private fun dp(value: Int): Int = (value * context.resources.displayMetrics.density).toInt()

    private fun <T> once(answer: (T) -> Unit): (T) -> Unit {
        var answered = false
        return { value ->
            if (!answered) {
                answered = true
                answer(value)
            }
        }
    }

    // ── Windows ─────────────────────────────────────────────────────────────

    private fun fullScreen(touchable: Boolean) =
        params(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT, focusable = false).apply {
            if (!touchable) flags = flags or WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE
        }

    private fun params(
        width: Int,
        height: Int,
        focusable: Boolean,
    ) = WindowManager
        .LayoutParams(
            width,
            height,
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
            (if (focusable) 0 else WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE) or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT,
        )

    private fun add(
        view: View,
        params: WindowManager.LayoutParams,
    ) {
        windowManager.addView(view, params)
        added += view
    }

    private fun remove(view: View) {
        if (added.remove(view)) windowManager.removeViewImmediate(view)
    }

    /** The violet edge light: shows that Alesle is in control of the screen. */
    @SuppressLint("ViewConstructor")
    private class GlowView(
        context: Context,
    ) : View(context) {
        private val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE }
        private val rect = RectF()
        private val density = context.resources.displayMetrics.density

        init {
            importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        }

        override fun onDraw(canvas: Canvas) {
            // Stacked strokes fading inwards stand in for the design's inset blur.
            for (layer in 0 until GLOW_LAYERS) {
                val inset = (layer * GLOW_STEP_DP + 1.5f) * density
                paint.strokeWidth = GLOW_STEP_DP * density
                paint.color = Color.argb(GLOW_ALPHA - layer * (GLOW_ALPHA / GLOW_LAYERS), 0x85, 0x68, 0xDB)
                rect.set(inset, inset, width - inset, height - inset)
                canvas.drawRoundRect(rect, GLOW_RADIUS_DP * density, GLOW_RADIUS_DP * density, paint)
            }
        }
    }

    /** A violet dot in a ring: the design's "working" orb, small. */
    @SuppressLint("ViewConstructor")
    private class SpinnerDot(
        context: Context,
    ) : View(context) {
        private val ring =
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE
                color = Color.rgb(0xE2, 0xE2, 0xE8)
            }
        private val arc =
            Paint(Paint.ANTI_ALIAS_FLAG).apply {
                style = Paint.Style.STROKE
                strokeCap = Paint.Cap.ROUND
                color = VIOLET_BOTTOM
            }
        private val dot = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = VIOLET_TOP }
        private val bounds = RectF()
        private var angle = 0f

        init {
            importantForAccessibility = IMPORTANT_FOR_ACCESSIBILITY_NO
        }

        override fun onDraw(canvas: Canvas) {
            val stroke = width / 10f
            ring.strokeWidth = stroke
            arc.strokeWidth = stroke
            bounds.set(stroke, stroke, width - stroke, height - stroke)
            canvas.drawOval(bounds, ring)
            canvas.drawArc(bounds, angle, SPINNER_SWEEP, false, arc)
            canvas.drawCircle(width / 2f, height / 2f, width / 6f, dot)
            angle = (angle + SPINNER_STEP) % FULL_TURN
            postInvalidateDelayed(FRAME_MS)
        }
    }

    companion object {
        const val COUNTDOWN_SECONDS = 3
        private const val CONCEAL_WAIT_MS = 500L
        private const val CONCEAL_FRAME_MS = 120L
        const val SECOND_MS = 1_000L
        private const val TOP_INSET_DP = 36

        private val INK = Color.rgb(0x15, 0x15, 0x1D)
        private val TEXT_2 = Color.rgb(0x5A, 0x5B, 0x6B)
        private val CANVAS = Color.rgb(0xF4, 0xF4, 0xF8)
        private val CAPSULE_GREY = Color.rgb(0xEE, 0xEE, 0xF2)
        private val VIOLET_TOP = Color.rgb(0xA0, 0x89, 0xF0)
        private val VIOLET_BOTTOM = Color.rgb(0x6B, 0x4E, 0xD0)
        private val BACKDROP = Color.argb(0x66, 0x15, 0x15, 0x1D)

        private const val GLOW_LAYERS = 6
        private const val GLOW_STEP_DP = 4f
        private const val GLOW_ALPHA = 150
        private const val GLOW_RADIUS_DP = 36f

        private const val SPINNER_SWEEP = 90f
        private const val SPINNER_STEP = 12f
        private const val FULL_TURN = 360f
        private const val FRAME_MS = 32L
    }
}

/** [base] with [locale]'s resources; [base] itself when there is no usable locale. */
internal fun localized(
    base: Context,
    locale: String?,
): Context {
    val tag = locale?.trim().orEmpty()
    if (tag.isEmpty()) return base
    val wanted = Locale.forLanguageTag(tag)
    if (wanted.language.isEmpty()) return base
    val configuration = Configuration(base.resources.configuration).apply { setLocale(wanted) }
    return base.createConfigurationContext(configuration)
}
