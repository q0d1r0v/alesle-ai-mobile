package com.alesle.ai.agent.vision

import android.accessibilityservice.AccessibilityService
import android.graphics.Bitmap
import android.os.Handler
import android.util.Base64
import android.view.Display
import androidx.core.graphics.scale
import java.io.ByteArrayOutputStream
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executor
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicReference
import kotlin.math.roundToInt

/** What a screenshot attempt gave. The image lives in memory only (SOW 03 A8). */
sealed interface Screenshot {
    /** JPEG, base64, long side ≤ [MAX_LONG_SIDE] px. */
    data class Image(
        val jpegBase64: String,
    ) : Screenshot

    /** The window forbids capture (FLAG_SECURE): the agent must not operate it (EC-8). */
    data object Secure : Screenshot

    data object Unavailable : Screenshot

    companion object {
        const val MAX_LONG_SIDE = 1280
        const val JPEG_QUALITY = 70
    }
}

/** Blocking: call off the main thread. */
fun interface ScreenshotSource {
    fun take(): Screenshot
}

/**
 * `AccessibilityService.takeScreenshot` (API 30+, no consent dialog). Android
 * allows about one capture per second; a "too soon" answer is retried once.
 */
class ServiceScreenshotSource(
    private val service: AccessibilityService,
    private val callbackHandler: Handler,
    private val sleep: (Long) -> Unit = Thread::sleep,
) : ScreenshotSource {
    override fun take(): Screenshot = attempt() ?: retry()

    private fun retry(): Screenshot {
        sleep(RETRY_AFTER_MS)
        return attempt() ?: Screenshot.Unavailable
    }

    /** The outcome, or null when Android said "too soon". */
    private fun attempt(): Screenshot? {
        val done = CountDownLatch(1)
        val outcome = AtomicReference<Screenshot?>(Screenshot.Unavailable)
        val executor = Executor { callbackHandler.post(it) }
        service.takeScreenshot(
            Display.DEFAULT_DISPLAY,
            executor,
            object : AccessibilityService.TakeScreenshotCallback {
                override fun onSuccess(result: AccessibilityService.ScreenshotResult) {
                    outcome.set(encode(result))
                    done.countDown()
                }

                override fun onFailure(errorCode: Int) {
                    // if/else, not when: the platform's @IntDef for this callback omits SECURE_WINDOW.
                    outcome.set(
                        if (errorCode == AccessibilityService.ERROR_TAKE_SCREENSHOT_SECURE_WINDOW) {
                            Screenshot.Secure
                        } else if (errorCode == AccessibilityService.ERROR_TAKE_SCREENSHOT_INTERVAL_TIME_SHORT) {
                            null
                        } else {
                            Screenshot.Unavailable
                        },
                    )
                    done.countDown()
                }
            },
        )
        if (!done.await(TIMEOUT_MS, TimeUnit.MILLISECONDS)) return Screenshot.Unavailable
        return outcome.get()
    }

    private fun encode(result: AccessibilityService.ScreenshotResult): Screenshot {
        val buffer = result.hardwareBuffer
        try {
            val hardware = Bitmap.wrapHardwareBuffer(buffer, result.colorSpace) ?: return Screenshot.Unavailable
            // Hardware bitmaps cannot be scaled or compressed in place.
            val software = hardware.copy(Bitmap.Config.ARGB_8888, false)
            hardware.recycle()
            return Screenshot.Image(toJpegBase64(software ?: return Screenshot.Unavailable))
        } finally {
            buffer.close()
        }
    }

    private companion object {
        const val RETRY_AFTER_MS = 1_100L
        const val TIMEOUT_MS = 3_000L
    }
}

/** The long side scaled down to [maxLong], keeping the aspect ratio; never scaled up. */
fun scaledSize(
    width: Int,
    height: Int,
    maxLong: Int = Screenshot.MAX_LONG_SIDE,
): Pair<Int, Int> {
    val long = maxOf(width, height)
    if (long <= maxLong) return width to height
    val scale = maxLong.toDouble() / long
    return maxOf(1, (width * scale).roundToInt()) to maxOf(1, (height * scale).roundToInt())
}

/** Scales, compresses and recycles [bitmap]. */
fun toJpegBase64(bitmap: Bitmap): String {
    val (width, height) = scaledSize(bitmap.width, bitmap.height)
    val scaled = if (width == bitmap.width && height == bitmap.height) bitmap else bitmap.scale(width, height)
    val out = ByteArrayOutputStream()
    scaled.compress(Bitmap.CompressFormat.JPEG, Screenshot.JPEG_QUALITY, out)
    if (scaled !== bitmap) scaled.recycle()
    bitmap.recycle()
    return Base64.encodeToString(out.toByteArray(), Base64.NO_WRAP)
}
