package com.alesle.ai.agent.service

import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder
import androidx.core.content.ContextCompat

/**
 * Keeps the process alive while a task runs and shows the ongoing
 * notification with "To'xtatish" (SOW 03 §8). It carries no agent logic: the
 * loop starts it when a task begins, updates the step text, and stops it when
 * the task ends. A press on "To'xtatish" goes to [StopRequests].
 *
 * Not restarted after the system kills it: the task is gone with the process
 * and the backend marks it interrupted (EC-1).
 */
class AgentForegroundService : Service() {
    private lateinit var notifications: AgentNotifications

    override fun onCreate() {
        super.onCreate()
        notifications = AgentNotifications(this).apply { ensureChannel() }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int,
    ): Int {
        if (intent?.action == ACTION_STOP) {
            StopRequests.request()
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }
        val notification = notifications.build(intent?.getStringExtra(EXTRA_STEP))
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            // TODO(sprint-4): add FOREGROUND_SERVICE_TYPE_MICROPHONE while listening for voice.
            startForeground(AgentNotifications.NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
        } else {
            startForeground(AgentNotifications.NOTIFICATION_ID, notification)
        }
        running = true
        return START_NOT_STICKY
    }

    override fun onDestroy() {
        running = false
        super.onDestroy()
    }

    companion object {
        const val ACTION_STOP = "com.alesle.ai.agent.STOP_TASK"
        const val EXTRA_STEP = "step"

        @Volatile
        var running = false
            private set

        /**
         * Starts the service for a task. False when Android refuses a
         * foreground service from the background (Android 12+); the caller
         * should then not start the task.
         */
        fun start(
            context: Context,
            step: String? = null,
        ): Boolean {
            val intent = Intent(context, AgentForegroundService::class.java).putExtra(EXTRA_STEP, step)
            return try {
                ContextCompat.startForegroundService(context, intent)
                true
            } catch (e: IllegalStateException) {
                // ForegroundServiceStartNotAllowedException (API 31) extends it; catching the
                // subclass would not resolve on Android 11.
                false
            }
        }

        /** Shows what the agent is doing now; ignored when no task runs. */
        fun updateStep(
            context: Context,
            step: String?,
        ) {
            if (running) AgentNotifications(context).update(step)
        }

        /** The task ended on its own: remove the notification, no stop request. */
        fun stop(context: Context) {
            context.stopService(Intent(context, AgentForegroundService::class.java))
        }
    }
}
