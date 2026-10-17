package com.alesle.ai.listen

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.PixelFormat
import android.graphics.RectF
import android.graphics.drawable.GradientDrawable
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.WindowManager
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.view.isVisible
import com.alesle.ai.AppVisibility
import com.alesle.ai.MainActivity
import com.alesle.ai.R
import com.alesle.ai.agent.AlesleAccessibilityService
import com.alesle.ai.agent.generated.LiveEventKind
import com.alesle.ai.agent.overlay.localized
import com.alesle.ai.agent.task.AgentTaskController
import kotlin.math.abs
import kotlin.math.hypot
import kotlin.math.sqrt

/**
 * The live conversation outside Alesle's screen (design: Gemini Live's
 * floating orb): a small orb at the edge of whatever app is in front, showing
 * whether Alesle listens, hears, thinks or speaks. Drag it anywhere; a tap
 * opens Mute, Open and End. It hides while a task works the screen (the
 * task's own overlay, with STOP, takes over) and whenever Alesle is in front.
 *
 * This object only follows the conversation and decides ([LiveBubbleState]);
 * the window itself belongs to the connected accessibility service
 * ([LiveBubbleWindow]): an accessibility overlay needs no extra permission
 * and is never part of the agent's snapshots. All window work runs on the
 * main thread.
 */
object LiveBubble {
    private val main = Handler(Looper.getMainLooper())
    private var installed = false
    private var taskRunning = false

    /** Windows refused in a row; a few more tries follow, then the next change tries again. */
    private var refusals = 0

    /** The last decision, logged only when it changes (no content: flags and the look). */
    private var lastReport: String? = null

    /** Where the user left it, for the next time it shows (null: the default spot). */
    internal var position: Pair<Int, Int>? = null

    /** Starts following the conversation; safe to call more than once. */
    fun install(context: Context) {
        main.post {
            if (installed) return@post
            installed = true
            HandsFree.onState { refresh() }
            // The level changes many times a second; the orb reads it as it draws.
            LiveVoice.onEvent { if (it.kind != LiveEventKind.LEVEL) refresh() }
            AppVisibility.onChange { refresh() }
            AgentTaskController.get(context.applicationContext).onRunning { running ->
                main.post {
                    taskRunning = running
                    refresh()
                }
            }
            refresh()
        }
    }

    /** Shows, updates or hides the bubble; also called when the accessibility service (re)connects. */
    fun refresh() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            main.post(::refresh)
            return
        }
        val state = HandsFree.state
        val inputs =
            BubbleInputs(
                listening = state.active,
                muted = state.muted,
                phase = LiveVoice.phase,
                appVisible = AppVisibility.visible,
                taskRunning = taskRunning,
                paused = state.paused,
            )
        val look = LiveBubbleState.look(inputs)
        val window = AlesleAccessibilityService.instance?.liveBubble
        report(inputs, look, window != null)
        if (window == null) return
        if (look == null) {
            refusals = 0
            window.hide()
            return
        }
        if (window.show(look, state.muted, LiveVoice.locale)) {
            refusals = 0
        } else if (++refusals <= MAX_REFUSALS) {
            main.postDelayed(::refresh, RETRY_MS)
        }
    }

    private fun report(
        inputs: BubbleInputs,
        look: BubbleLook?,
        service: Boolean,
    ) {
        val line =
            "look=$look listening=${inputs.listening} muted=${inputs.muted} paused=${inputs.paused} " +
                "phase=${inputs.phase} appVisible=${inputs.appVisible} task=${inputs.taskRunning} service=$service"
        if (line == lastReport) return
        lastReport = line
        Log.i(TAG, line)
    }

    private const val TAG = "AlesleBubble"
    private const val RETRY_MS = 1_000L
    private const val MAX_REFUSALS = 5
}

/** The bubble's window, owned by the accessibility service that may draw it. */
class LiveBubbleWindow(
    private val service: Context,
) {
    private val windowManager: WindowManager? = service.getSystemService(WindowManager::class.java)
    private var root: View? = null
    private var orb: OrbView? = null
    private var panel: View? = null
    private var muteLabel: TextView? = null
    private var params: WindowManager.LayoutParams? = null

    /** False when the window could not be added (the service's token is not ready yet). */
    fun show(
        look: BubbleLook,
        muted: Boolean,
        locale: String?,
    ): Boolean {
        if (root == null && !add(locale)) return false
        orb?.let { if (it.look != look) it.look = look }
        muteLabel?.setText(if (muted) R.string.notification_listening_unmute else R.string.notification_listening_mute)
        return true
    }

    fun hide() {
        val view = root ?: return
        orb?.stop()
        runCatching { windowManager?.removeView(view) }
        root = null
        orb = null
        panel = null
        muteLabel = null
        params = null
    }

    @SuppressLint("ClickableViewAccessibility")
    private fun add(locale: String?): Boolean {
        val manager = windowManager ?: return false
        val context = localized(service, locale)
        val metrics = context.resources.displayMetrics
        val size = dp(context, ORB_DP)
        val margin = dp(context, MARGIN_DP)

        val row =
            LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
            }
        val orbView = OrbView(context).apply { contentDescription = context.getString(R.string.bubble_label) }
        row.addView(orbView, LinearLayout.LayoutParams(size, size))
        val actions = buildPanel(context)
        actions.isVisible = false
        row.addView(actions, LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT))

        val (startX, startY) = LiveBubble.position ?: ((metrics.widthPixels - size - margin) to (metrics.heightPixels * START_Y).toInt())
        val layout =
            WindowManager
                .LayoutParams(
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.WRAP_CONTENT,
                    WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY,
                    WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
                    PixelFormat.TRANSLUCENT,
                ).apply {
                    gravity = Gravity.TOP or Gravity.START
                    x = startX
                    y = startY
                }
        orbView.setOnTouchListener(Dragger(context, row, layout, size, margin))
        try {
            manager.addView(row, layout)
        } catch (e: RuntimeException) {
            // The service lost its window token; the bubble stays off until it is back.
            Log.w(TAG, "Bubble window refused: ${e.javaClass.simpleName}")
            return false
        }
        root = row
        orb = orbView
        panel = actions
        params = layout
        return true
    }

    private fun togglePanel() {
        val actions = panel ?: return
        actions.isVisible = !actions.isVisible
        // An open panel near the right edge would run off screen: bring it inside.
        val view = root ?: return
        val layout = params ?: return
        view.post {
            val width = view.resources.displayMetrics.widthPixels
            if (layout.x + view.width > width) {
                layout.x = maxOf(0, width - view.width)
                runCatching { windowManager?.updateViewLayout(view, layout) }
            }
        }
    }

    private fun buildPanel(context: Context): View {
        val panel =
            LinearLayout(context).apply {
                orientation = LinearLayout.HORIZONTAL
                gravity = Gravity.CENTER_VERTICAL
                setPadding(dp(context, 6), dp(context, 6), dp(context, 6), dp(context, 6))
                background = rounded(Color.WHITE, dp(context, 28).toFloat())
                elevation = dp(context, 8).toFloat()
            }
        val app = context.applicationContext
        val mute =
            button(context, context.getString(R.string.notification_listening_mute), INK, CAPSULE_GREY) {
                ListeningService.setMuted(app, !HandsFree.state.muted)
            }
        muteLabel = mute
        panel.addView(mute, gap(context))
        panel.addView(
            button(context, context.getString(R.string.bubble_open), INK, CAPSULE_GREY) {
                togglePanel()
                val open =
                    Intent(app, MainActivity::class.java)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                runCatching { service.startActivity(open) }
            },
            gap(context),
        )
        panel.addView(
            button(context, context.getString(R.string.bubble_end), Color.WHITE, INK) { LiveVoice.end(app) },
            gap(context),
        )
        return panel
    }

    private fun button(
        context: Context,
        text: String,
        color: Int,
        fill: Int,
        onClick: () -> Unit,
    ) = TextView(context).apply {
        this.text = text
        setTextColor(color)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
        paint.isFakeBoldText = true
        setPadding(dp(context, 14), dp(context, 10), dp(context, 14), dp(context, 10))
        background = rounded(fill, dp(context, 22).toFloat())
        setOnClickListener { onClick() }
    }

    private fun gap(context: Context) =
        LinearLayout.LayoutParams(LinearLayout.LayoutParams.WRAP_CONTENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply {
            marginStart = dp(context, 6)
        }

    private fun rounded(
        color: Int,
        radius: Float,
    ) = GradientDrawable().apply {
        setColor(color)
        cornerRadius = radius
    }

    private fun dp(
        context: Context,
        value: Int,
    ): Int = (value * context.resources.displayMetrics.density).toInt()

    /** Drag to move, drop to settle at the nearer edge; a touch that does not move is a tap. */
    private inner class Dragger(
        context: Context,
        private val view: View,
        private val layout: WindowManager.LayoutParams,
        private val size: Int,
        private val margin: Int,
    ) : View.OnTouchListener {
        private val slop = ViewConfiguration.get(context).scaledTouchSlop
        private var downX = 0f
        private var downY = 0f
        private var startX = 0
        private var startY = 0
        private var dragging = false

        @SuppressLint("ClickableViewAccessibility")
        override fun onTouch(
            v: View,
            event: MotionEvent,
        ): Boolean {
            when (event.actionMasked) {
                MotionEvent.ACTION_DOWN -> {
                    downX = event.rawX
                    downY = event.rawY
                    startX = layout.x
                    startY = layout.y
                    dragging = false
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = event.rawX - downX
                    val dy = event.rawY - downY
                    if (!dragging && hypot(dx, dy) > slop) dragging = true
                    if (dragging) {
                        layout.x = startX + dx.toInt()
                        layout.y = startY + dy.toInt()
                        update()
                    }
                }
                MotionEvent.ACTION_UP -> {
                    if (!dragging) {
                        togglePanel()
                        return true
                    }
                    val metrics = view.resources.displayMetrics
                    layout.x = LiveBubbleState.snapX(layout.x, size, metrics.widthPixels, margin)
                    layout.y = LiveBubbleState.clampY(layout.y, size, metrics.heightPixels, margin)
                    LiveBubble.position = layout.x to layout.y
                    update()
                }
                MotionEvent.ACTION_CANCEL -> dragging = false
            }
            return true
        }

        private fun update() {
            runCatching { windowManager?.updateViewLayout(view, layout) }
        }
    }

    /**
     * The orb: a violet sphere that moves with the voice. While listening it
     * swells with what the microphone hears and sends out ripples when the
     * user speaks; while Alesle speaks it follows Alesle's voice; it spins
     * while thinking and rests grey when muted or the microphone is busy.
     */
    private class OrbView(
        context: Context,
    ) : View(context) {
        private val fill = Paint(Paint.ANTI_ALIAS_FLAG)
        private val glow = Paint(Paint.ANTI_ALIAS_FLAG)
        private val ring = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE }
        private val ripple = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE }
        private val arc = RectF()

        /** Redraws every frame while it moves. Frames, not an animator: it keeps moving with system animations turned off. */
        private var moving = false

        /** The level as drawn: eased toward the live one, so the orb moves smoothly. */
        private var shown = 0f

        /** When each ripple started (uptime ms). */
        private val ripples = ArrayList<Long>()
        private var lastRipple = 0L

        var look: BubbleLook = BubbleLook.LISTENING
            set(value) {
                field = value
                if (value.still) {
                    moving = false
                    ripples.clear()
                    shown = 0f
                } else if (isAttachedToWindow) {
                    move()
                }
                invalidate()
            }

        init {
            elevation = 8 * resources.displayMetrics.density
        }

        override fun onAttachedToWindow() {
            super.onAttachedToWindow()
            if (!look.still) move()
        }

        override fun onDetachedFromWindow() {
            moving = false
            super.onDetachedFromWindow()
        }

        fun stop() {
            moving = false
        }

        private fun move() {
            if (moving) return
            moving = true
            postInvalidateOnAnimation()
        }

        override fun onDraw(canvas: Canvas) {
            val cx = width / 2f
            val cy = height / 2f
            val full = minOf(width, height) / 2f
            val now = SystemClock.uptimeMillis()
            val cycle = if (look == BubbleLook.HEARING || look == BubbleLook.SPEAKING) FAST_MS else CYCLE_MS
            val t = (now % cycle) / cycle.toFloat()
            val wave = (kotlin.math.sin(t * 2 * Math.PI) * 0.5 + 0.5).toFloat()
            val voiced = look == BubbleLook.LISTENING || look == BubbleLook.HEARING || look == BubbleLook.SPEAKING
            val target =
                when (look) {
                    BubbleLook.SPEAKING -> VoiceLevel.voice
                    BubbleLook.LISTENING, BubbleLook.HEARING -> VoiceLevel.mic
                    else -> 0f
                }
            // A gentle curve: ordinary speech already moves the orb clearly.
            shown += (sqrt(target) - shown) * EASE
            if (voiced && shown > RIPPLE_AT && now - lastRipple > RIPPLE_EVERY_MS) {
                ripples += now
                lastRipple = now
            }
            ripples.removeAll { now - it > RIPPLE_MS }

            val core = if (voiced) full * (0.48f + 0.04f * wave + 0.3f * shown) else full * 0.6f
            val color =
                when (look) {
                    BubbleLook.MUTED, BubbleLook.PAUSED -> MUTED_GREY
                    BubbleLook.CONNECTING -> VIOLET_SOFT
                    BubbleLook.HEARING -> VIOLET_DEEP
                    else -> VIOLET
                }

            // Ripples: rings that leave the orb while someone speaks.
            for (start in ripples) {
                val p = (now - start) / RIPPLE_MS.toFloat()
                // Light lilac: seen on dark and light screens alike.
                ripple.color = LILAC
                ripple.alpha = (230 * (1f - p)).toInt().coerceIn(0, 255)
                ripple.strokeWidth = full * 0.08f * (1f - p) + 1.5f
                canvas.drawCircle(cx, cy, core + (full * 0.97f - core) * p, ripple)
            }
            // A soft halo that grows with the voice.
            if (voiced && shown > 0.02f) {
                glow.color = LILAC
                glow.alpha = (150 * shown).toInt().coerceIn(0, 255)
                canvas.drawCircle(cx, cy, minOf(full, core + full * 0.22f * shown), glow)
            }
            fill.color = color
            canvas.drawCircle(cx, cy, core, fill)

            ring.strokeWidth = full * 0.1f
            ring.color = VIOLET_SOFT
            arc.set(cx - full * 0.86f, cy - full * 0.86f, cx + full * 0.86f, cy + full * 0.86f)
            when (look) {
                BubbleLook.THINKING, BubbleLook.CONNECTING -> canvas.drawArc(arc, t * 360f, 100f, false, ring)
                BubbleLook.MUTED -> {
                    ring.color = Color.WHITE
                    ring.strokeWidth = full * 0.12f
                    val d = core * 0.5f
                    canvas.drawLine(cx - d, cy - d, cx + d, cy + d, ring)
                }
                BubbleLook.PAUSED -> {
                    // Two bars: waiting for the microphone.
                    ring.color = Color.WHITE
                    ring.strokeWidth = full * 0.12f
                    val h = core * 0.45f
                    val gap = core * 0.22f
                    canvas.drawLine(cx - gap, cy - h, cx - gap, cy + h, ring)
                    canvas.drawLine(cx + gap, cy - h, cx + gap, cy + h, ring)
                }
                else ->
                    if (ripples.isEmpty()) {
                        // At rest: a ring that breathes, so the orb still shows it listens.
                        ring.alpha = (255 * (1f - abs(wave - 0.5f) * 1.2f)).toInt().coerceIn(40, 255)
                        canvas.drawCircle(cx, cy, full * 0.86f, ring)
                    }
            }
            if (moving) postInvalidateOnAnimation()
        }

        private val BubbleLook.still: Boolean get() = this == BubbleLook.MUTED || this == BubbleLook.PAUSED

        companion object {
            private const val CYCLE_MS = 1_600L
            private const val FAST_MS = 700L
            private const val EASE = 0.35f
            private const val RIPPLE_AT = 0.35f
            private const val RIPPLE_EVERY_MS = 220L
            private const val RIPPLE_MS = 900L
        }
    }

    private companion object {
        const val TAG = "AlesleBubble"
        const val ORB_DP = 64
        const val MARGIN_DP = 8
        const val START_Y = 0.35f
        val INK = Color.rgb(0x15, 0x15, 0x1D)
        val CAPSULE_GREY = Color.rgb(0xEE, 0xEE, 0xF2)
        val VIOLET = Color.rgb(0x85, 0x68, 0xDB)
        val VIOLET_SOFT = Color.argb(0xB0, 0xA0, 0x89, 0xF0)
        val VIOLET_DEEP = Color.rgb(0x6C, 0x4B, 0xD6)
        val LILAC = Color.rgb(0xC4, 0xB5, 0xFF)
        val MUTED_GREY = Color.rgb(0x8A, 0x8B, 0x99)
    }
}
