package com.alesle.ai.agent.service

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.alesle.ai.R

/** The ongoing "Alesle ishlayapti — To'xtatish" notification of a running task. */
class AgentNotifications(
    private val context: Context,
) {
    private val manager = context.getSystemService(NotificationManager::class.java)

    fun ensureChannel() {
        val channel =
            NotificationChannel(CHANNEL_ID, context.getString(R.string.notification_channel_agent), NotificationManager.IMPORTANCE_LOW)
                .apply { setShowBadge(false) }
        manager.createNotificationChannel(channel)
    }

    /**
     * [step] says what the agent is doing ("Telegram'ni ochyapman"). It can
     * name people or apps, so the lock screen shows only the public version.
     */
    fun build(step: String?): Notification {
        val title = context.getString(R.string.notification_agent_running)
        val public =
            base(title)
                .build()
        return base(title)
            .setContentText(step)
            .setVisibility(NotificationCompat.VISIBILITY_PRIVATE)
            .setPublicVersion(public)
            .setContentIntent(openApp())
            .addAction(0, context.getString(R.string.notification_agent_stop), stopTask())
            .build()
    }

    fun update(step: String?) {
        manager.notify(NOTIFICATION_ID, build(step))
    }

    private fun base(title: String) =
        NotificationCompat
            .Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_stat_alesle)
            .setContentTitle(title)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setSilent(true)
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            // Android 12+ may delay a service notification by 10 s; a running agent must be visible at once.
            .setForegroundServiceBehavior(NotificationCompat.FOREGROUND_SERVICE_IMMEDIATE)

    private fun openApp(): PendingIntent? {
        val launch = context.packageManager.getLaunchIntentForPackage(context.packageName) ?: return null
        return PendingIntent.getActivity(context, REQUEST_OPEN, launch, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }

    private fun stopTask(): PendingIntent {
        val stop = Intent(context, AgentForegroundService::class.java).setAction(AgentForegroundService.ACTION_STOP)
        return PendingIntent.getService(context, REQUEST_STOP, stop, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }

    companion object {
        const val CHANNEL_ID = "agent_task"
        const val NOTIFICATION_ID = 1
        private const val REQUEST_OPEN = 1
        private const val REQUEST_STOP = 2
    }
}
