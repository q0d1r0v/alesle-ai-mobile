package com.alesle.ai.agent.service

import android.app.Application
import android.app.Notification
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import androidx.test.core.app.ApplicationProvider
import io.mockk.every
import io.mockk.mockk
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config

// Uzbek is the default locale of the app; Robolectric would otherwise pick values-en.
@RunWith(RobolectricTestRunner::class)
@Config(qualifiers = "uz")
class AgentForegroundServiceTest {
    private val app = ApplicationProvider.getApplicationContext<Application>()
    private val manager = app.getSystemService(NotificationManager::class.java)
    private val stops = mutableListOf<Unit>()
    private val registration = StopRequests.register { stops += Unit }

    @After
    fun tearDown() = registration.close()

    private fun startCommand(intent: Intent) =
        Robolectric.buildService(AgentForegroundService::class.java, intent).create().startCommand(0, 1)

    private fun startIntent(step: String? = null) =
        Intent(app, AgentForegroundService::class.java).putExtra(AgentForegroundService.EXTRA_STEP, step)

    @Test
    fun `goes foreground with the running notification and a stop action`() {
        val service = startCommand(startIntent("Telegram'ni ochyapman")).get()

        val shadow = shadowOf(service)
        val notification = shadow.lastForegroundNotification
        assertEquals(AgentNotifications.NOTIFICATION_ID, shadow.lastForegroundNotificationId)
        assertEquals("Alesle ishlayapti", notification.extras.getString(Notification.EXTRA_TITLE))
        assertEquals("Telegram'ni ochyapman", notification.extras.getCharSequence(Notification.EXTRA_TEXT))
        assertTrue(notification.flags and Notification.FLAG_ONGOING_EVENT != 0)
        assertEquals("To'xtatish", notification.actions.single().title)
        assertTrue(AgentForegroundService.running)
    }

    @Test
    fun `keeps the step off the lock screen`() {
        val notification = shadowOf(startCommand(startIntent("Onam'ga yozyapman")).get()).lastForegroundNotification
        assertEquals(Notification.VISIBILITY_PRIVATE, notification.visibility)
        val public = notification.publicVersion
        assertNotNull(public)
        assertEquals("Alesle ishlayapti", public.extras.getString(Notification.EXTRA_TITLE))
        assertNull(public.extras.getCharSequence(Notification.EXTRA_TEXT))
    }

    @Test
    fun `creates a quiet channel`() {
        startCommand(startIntent())
        val channel = manager.getNotificationChannel(AgentNotifications.CHANNEL_ID)
        assertEquals(NotificationManager.IMPORTANCE_LOW, channel.importance)
        assertEquals("Agent vazifalari", channel.name)
        assertFalse(channel.canShowBadge())
    }

    @Test
    fun `the stop action requests a stop and ends the service`() {
        val controller = startCommand(startIntent())
        val service = controller.get()

        val stopIntent =
            shadowOf(
                shadowOf(service)
                    .lastForegroundNotification.actions
                    .single()
                    .actionIntent,
            ).savedIntent
        assertEquals(AgentForegroundService.ACTION_STOP, stopIntent.action)

        service.onStartCommand(stopIntent, 0, 2)

        assertEquals(1, stops.size)
        assertTrue(shadowOf(service).isStoppedBySelf)
        assertTrue(shadowOf(service).isForegroundStopped)
    }

    @Test
    fun `a task that ends before the service goes foreground still ends it, without the crash`() {
        // No service running (the flag is process-wide).
        startCommand(startIntent()).destroy()
        assertTrue(AgentForegroundService.start(app, "x"))
        // The task is over before Android ran onStartCommand.
        AgentForegroundService.stop(app)
        val service = startCommand(startIntent()).get()
        assertTrue(shadowOf(service).isStoppedBySelf)
        assertTrue(shadowOf(service).isForegroundStopped)

        // Once foreground, a stop goes straight to the service.
        val running = startCommand(startIntent()).get()
        assertFalse(shadowOf(running).isStoppedBySelf)
        AgentForegroundService.stop(app)
        assertEquals(
            AgentForegroundService::class.java.name,
            shadowOf(app).nextStoppedService.component?.className,
        )
    }

    @Test
    fun `is not running once destroyed and ignores step updates then`() {
        val controller = startCommand(startIntent())
        controller.destroy()
        assertFalse(AgentForegroundService.running)

        AgentForegroundService.updateStep(app, "late step")
        val texts = shadowOf(manager).allNotifications.map { it.extras.getCharSequence(Notification.EXTRA_TEXT) }
        assertFalse(texts.contains("late step"))
    }

    @Test
    fun `updates the step of a running task`() {
        startCommand(startIntent("birinchi"))
        AgentForegroundService.updateStep(app, "ikkinchi")
        val posted = shadowOf(manager).getNotification(AgentNotifications.NOTIFICATION_ID)
        assertEquals("ikkinchi", posted.extras.getCharSequence(Notification.EXTRA_TEXT))
    }

    @Test
    fun `start and stop go through the context`() {
        assertTrue(AgentForegroundService.start(app, "salom"))
        val started = shadowOf(app).nextStartedService
        assertEquals(AgentForegroundService::class.java.name, started.component?.className)
        assertEquals("salom", started.getStringExtra(AgentForegroundService.EXTRA_STEP))

        AgentForegroundService.stop(app)
        assertEquals(AgentForegroundService::class.java.name, shadowOf(app).nextStoppedService.component?.className)
    }

    @Test
    fun `reports a start Android refuses from the background`() {
        val context = mockk<Context>()
        every { context.startForegroundService(any()) } throws IllegalStateException("not allowed")
        every { context.packageName } returns app.packageName
        assertFalse(AgentForegroundService.start(context))
    }

    @Test
    @Config(sdk = [30])
    fun `goes foreground on Android 11 too`() {
        val service: Service = startCommand(startIntent()).get()
        assertEquals(AgentNotifications.NOTIFICATION_ID, shadowOf(service).lastForegroundNotificationId)
    }

    @Test
    @Config(qualifiers = "ru")
    fun `speaks Russian on a Russian phone`() {
        val notification = shadowOf(startCommand(startIntent()).get()).lastForegroundNotification
        assertEquals("Alesle работает", notification.extras.getString(Notification.EXTRA_TITLE))
        assertEquals("Остановить", notification.actions.single().title)
    }

    @Test
    fun `stop requests reach registered listeners until closed`() {
        val calls = mutableListOf<String>()
        val handle = StopRequests.register { calls += "a" }
        StopRequests.request()
        handle.close()
        StopRequests.request()
        assertEquals(listOf("a"), calls)
    }
}
