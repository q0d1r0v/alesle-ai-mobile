package com.alesle.ai

import android.content.Context
import com.alesle.ai.agent.AccessibilityStatus
import com.alesle.ai.agent.AgentHostApiImpl
import com.alesle.ai.agent.generated.AgentEventsApi
import com.alesle.ai.agent.generated.AgentHostApi
import com.alesle.ai.agent.generated.ListenEventsApi
import com.alesle.ai.agent.generated.ListenHostApi
import com.alesle.ai.agent.task.AgentTaskController
import com.alesle.ai.listen.HandsFree
import com.alesle.ai.listen.ListenHostApiImpl
import com.alesle.ai.listen.LiveVoice
import com.alesle.ai.listen.toMessage
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.launch
import java.io.File

/**
 * One Flutter engine per process, outliving the activity: a live
 * conversation and the tasks it starts are run from Dart, and they go on in
 * other apps after Alesle's screen is closed (swiped from recents, or
 * reclaimed by the system). The first activity runs the Dart entrypoint with
 * its intent; later ones attach to the engine that is already running.
 */
object AppEngine {
    private const val ID = "alesle"
    private val scope = MainScope()

    @Volatile
    private var bridged: FlutterEngine? = null

    fun get(context: Context): FlutterEngine =
        synchronized(this) {
            val cache = FlutterEngineCache.getInstance()
            cache.get(ID) ?: FlutterEngine(context.applicationContext).also { cache.put(ID, it) }
        }

    /**
     * The calls and events that need no activity (tasks, hands-free, Live),
     * wired once per engine: they keep working while no screen is open.
     */
    fun bridge(
        engine: FlutterEngine,
        context: Context,
    ) {
        synchronized(this) {
            if (bridged === engine) return
            bridged = engine
        }
        val app = context.applicationContext
        val messenger = engine.dartExecutor.binaryMessenger
        val tasks = AgentTaskController.get(app)
        AgentHostApi.setUp(
            messenger,
            AgentHostApiImpl(context = app, accessibilityStatus = AccessibilityStatus(app), tasks = tasks),
        )
        ListenHostApi.setUp(messenger, ListenHostApiImpl(app))
        val events = AgentEventsApi(messenger)
        tasks.listener = { event ->
            // Pigeon sends on the platform thread; a Dart side that is gone is fine to miss.
            scope.launch { runCatching { events.onStepEvent(event) } }
        }
        val listen = ListenEventsApi(messenger)
        HandsFree.onState { state -> scope.launch { runCatching { listen.onListenState(state.toMessage()) } } }
        LiveVoice.onEvent { event -> scope.launch { runCatching { listen.onLiveEvent(event) } } }
        HandsFree.onUtterance { path ->
            scope.launch {
                // No Dart to take it: the audio is not kept.
                runCatching { listen.onUtterance(path) }.onFailure { File(path).delete() }
            }
        }
    }
}

/** Whether Alesle's own screen is in front (the live bubble shows only when it is not). */
object AppVisibility {
    private val listeners = java.util.concurrent.CopyOnWriteArrayList<(Boolean) -> Unit>()

    @Volatile
    var visible = false
        private set

    fun set(value: Boolean) {
        if (value == visible) return
        visible = value
        listeners.forEach { it(value) }
    }

    fun onChange(listener: (Boolean) -> Unit): AutoCloseable {
        listeners += listener
        return AutoCloseable { listeners -= listener }
    }
}
