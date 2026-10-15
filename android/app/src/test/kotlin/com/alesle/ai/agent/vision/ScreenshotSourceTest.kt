package com.alesle.ai.agent.vision

import android.accessibilityservice.AccessibilityService
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.os.Handler
import android.util.Base64
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import java.util.concurrent.Executor

@RunWith(RobolectricTestRunner::class)
class ScreenshotSourceTest {
    @Test
    fun `scales the long side down to 1280, never up`() {
        assertEquals(576 to 1280, scaledSize(1220, 2712))
        assertEquals(1280 to 720, scaledSize(1920, 1080))
        assertEquals(800 to 600, scaledSize(800, 600))
        assertEquals(1 to 1280, scaledSize(1, 100_000))
    }

    @Test
    fun `encodes a JPEG within the size limit and frees the bitmap`() {
        val bitmap = Bitmap.createBitmap(1220, 2712, Bitmap.Config.ARGB_8888).apply { eraseColor(Color.WHITE) }
        val encoded = toJpegBase64(bitmap)
        assertTrue(bitmap.isRecycled)
        val bytes = Base64.decode(encoded, Base64.NO_WRAP)
        // JPEG magic number.
        assertEquals(0xFF.toByte(), bytes[0])
        assertEquals(0xD8.toByte(), bytes[1])
        val options = BitmapFactory.Options().apply { inJustDecodeBounds = true }
        BitmapFactory.decodeByteArray(bytes, 0, bytes.size, options)
        assertTrue(maxOf(options.outWidth, options.outHeight) <= Screenshot.MAX_LONG_SIDE)
    }

    private fun serviceFailingWith(vararg codes: Int): AccessibilityService {
        val service = mockk<AccessibilityService>()
        val queue = ArrayDeque(codes.toList())
        every { service.takeScreenshot(any(), any(), any()) } answers {
            val executor = secondArg<Executor>()
            val callback = thirdArg<AccessibilityService.TakeScreenshotCallback>()
            val code = queue.removeFirst()
            executor.execute { callback.onFailure(code) }
        }
        return service
    }

    /** A handler that runs callbacks at once, as if on another thread. */
    private val direct =
        mockk<Handler>().also { handler ->
            every { handler.post(any()) } answers {
                firstArg<Runnable>().run()
                true
            }
        }

    @Test
    fun `reports a secure window`() {
        val service = serviceFailingWith(AccessibilityService.ERROR_TAKE_SCREENSHOT_SECURE_WINDOW)
        assertEquals(Screenshot.Secure, ServiceScreenshotSource(service, direct).take())
    }

    @Test
    fun `retries once when asked too soon`() {
        val sleeps = mutableListOf<Long>()
        val service =
            serviceFailingWith(
                AccessibilityService.ERROR_TAKE_SCREENSHOT_INTERVAL_TIME_SHORT,
                AccessibilityService.ERROR_TAKE_SCREENSHOT_SECURE_WINDOW,
            )
        assertEquals(Screenshot.Secure, ServiceScreenshotSource(service, direct) { sleeps += it }.take())
        assertEquals(1, sleeps.size)
        verify(exactly = 2) { service.takeScreenshot(any(), any(), any()) }

        val twice =
            serviceFailingWith(
                AccessibilityService.ERROR_TAKE_SCREENSHOT_INTERVAL_TIME_SHORT,
                AccessibilityService.ERROR_TAKE_SCREENSHOT_INTERVAL_TIME_SHORT,
            )
        assertEquals(Screenshot.Unavailable, ServiceScreenshotSource(twice, direct) {}.take())
    }

    @Test
    fun `any other failure means no picture`() {
        val service = serviceFailingWith(AccessibilityService.ERROR_TAKE_SCREENSHOT_INTERNAL_ERROR)
        assertEquals(Screenshot.Unavailable, ServiceScreenshotSource(service, direct).take())
    }
}
