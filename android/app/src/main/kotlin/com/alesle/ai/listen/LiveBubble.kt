package com.alesle.ai.listen

import android.animation.ValueAnimator
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
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.ViewConfiguration
import android.view.WindowManager
import android.view.animation.LinearInterpolator
import android.widget.LinearLayout
import android.widget.TextView
import androidx.core.view.isVisible
import com.alesle.ai.AppVisibility
import com.alesle.ai.MainActivity
import com.alesle.ai.R
import com.alesle.ai.agent.AlesleAccessibilityService
import com.alesle.ai.agent.overlay.localized
import com.alesle.ai.agent.task.AgentTaskController
import kotlin.math.abs
import kotlin.math.hypot

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

    /** Where the user left it, for the next time it shows (null: the default spot). */
    internal var position: Pair<Int, Int>? = null

    /** Starts following the conversation; safe to call more than once. */
    fun install(context: Context) {
        main.post {
            if (installed) return@post
            installed = true
            HandsFree.onState { refresh() }
            LiveVoice.onEvent { refresh() }
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

    private fun refresh() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            main.post(::refresh)
            return
        }
        val state = HandsFree.state
        val look =
            LiveBubbleState.look(
                BubbleInputs(
                    listening = state.active,
                    muted = state.muted,
                    phase = LiveVoice.phase,
                    appVisible = AppVisibility.visible,
                    taskRunning = taskRunning,
                ),
            )
        val window = AlesleAccessibilityService.instance?.liveBubble ?: return
        if (look == null) window.hide() else window.show(look, state.muted, LiveVoice.locale)
    }
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

    fun show(
        look: BubbleLook,
        muted: Boolean,
        locale: String?,
    ) {
        if (root == null && !add(locale)) return
        orb?.let { if (it.look != look) it.look = look }
        muteLabel?.setText(if (muted) R.string.notification_listening_unmute else R.string.notification_listening_mute)
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

    /** The orb: a violet sphere whose ring breathes, pulses or spins with the conversation. */
    private class OrbView(
        context: Context,
    ) : View(context) {
        private val fill = Paint(Paint.ANTI_ALIAS_FLAG)
        private val ring = Paint(Paint.ANTI_ALIAS_FLAG).apply { style = Paint.Style.STROKE }
        private val arc = RectF()
        private var t = 0f
        private val animator =
            ValueAnimator.ofFloat(0f, 1f).apply {
                duration = CYCLE_MS
                repeatCount = ValueAnimator.INFINITE
                interpolator = LinearInterpolator()
                addUpdateListener {
                    t = it.animatedValue as Float
                    invalidate()
                }
            }

        var look: BubbleLook = BubbleLook.LISTENING
            set(value) {
                field = value
                animator.duration =
                    when (value) {
                        BubbleLook.HEARING, BubbleLook.SPEAKING -> FAST_MS
                        else -> CYCLE_MS
                    }
                if (value == BubbleLook.MUTED) {
                    animator.cancel()
                } else if (!animator.isStarted) {
                    animator.start()
                }
                invalidate()
            }

        init {
            elevation = 8 * resources.displayMetrics.density
        }

        override fun onAttachedToWindow() {
            super.onAttachedToWindow()
            if (look != BubbleLook.MUTED) animator.start()
        }

        override fun onDetachedFromWindow() {
            animator.cancel()
            super.onDetachedFromWindow()
        }

        fun stop() = animator.cancel()

        override fun onDraw(canvas: Canvas) {
            val cx = width / 2f
            val cy = height / 2f
            val full = minOf(width, height) / 2f
            val wave = (kotlin.math.sin(t * 2 * Math.PI) * 0.5 + 0.5).toFloat()
            val core =
                full *
                    when (look) {
                        BubbleLook.SPEAKING -> 0.62f + 0.12f * wave
                        BubbleLook.HEARING -> 0.66f + 0.08f * wave
                        BubbleLook.LISTENING -> 0.66f + 0.04f * wave
                        else -> 0.66f
                    }
            fill.color =
                when (look) {
                    BubbleLook.MUTED -> MUTED_GREY
                    BubbleLook.CONNECTING -> VIOLET_SOFT
                    else -> VIOLET
                }
            canvas.drawCircle(cx, cy, core, fill)
            ring.strokeWidth = full * 0.1f
            ring.color = if (look == BubbleLook.MUTED) MUTED_GREY else VIOLET_SOFT
            arc.set(cx - full * 0.88f, cy - full * 0.88f, cx + full * 0.88f, cy + full * 0.88f)
            when (look) {
                BubbleLook.THINKING, BubbleLook.CONNECTING -> canvas.drawArc(arc, t * 360f, 100f, false, ring)
                BubbleLook.MUTED -> {
                    ring.color = Color.WHITE
                    ring.strokeWidth = full * 0.12f
                    val d = core * 0.5f
                    canvas.drawLine(cx - d, cy - d, cx + d, cy + d, ring)
                }
                else -> {
                    ring.alpha = (255 * (1f - abs(wave - 0.5f) * 1.2f)).toInt().coerceIn(40, 255)
                    canvas.drawCircle(cx, cy, full * 0.88f, ring)
                }
            }
        }

        companion object {
            private const val CYCLE_MS = 1_600L
            private const val FAST_MS = 700L
        }
    }

    private companion object {
        const val TAG = "AlesleBubble"
        const val ORB_DP = 56
        const val MARGIN_DP = 8
        const val START_Y = 0.35f
        val INK = Color.rgb(0x15, 0x15, 0x1D)
        val CAPSULE_GREY = Color.rgb(0xEE, 0xEE, 0xF2)
        val VIOLET = Color.rgb(0x85, 0x68, 0xDB)
        val VIOLET_SOFT = Color.argb(0xB0, 0xA0, 0x89, 0xF0)
        val MUTED_GREY = Color.rgb(0x8A, 0x8B, 0x99)
    }
}
