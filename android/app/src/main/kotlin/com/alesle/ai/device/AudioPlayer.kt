package com.alesle.ai.device

import android.media.AudioAttributes
import android.media.MediaPlayer
import com.alesle.ai.listen.HandsFree

/**
 * Plays the agent's spoken reply; one at a time, released when done. While
 * it plays, hands-free listening drops what it hears: Alesle must not take
 * its own voice for a command.
 */
class AudioPlayer(
    private val newPlayer: () -> MediaPlayer = ::MediaPlayer,
    private val speaking: (Boolean) -> Unit = { HandsFree.setSpeaking(it) },
) {
    private var player: MediaPlayer? = null

    fun play(path: String) {
        stop()
        val created = newPlayer()
        try {
            created.setAudioAttributes(
                AudioAttributes
                    .Builder()
                    .setUsage(AudioAttributes.USAGE_ASSISTANT)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build(),
            )
            created.setDataSource(path)
            created.setOnCompletionListener { finished ->
                finished.release()
                if (player === finished) {
                    player = null
                    speaking(false)
                }
            }
            speaking(true)
            created.prepare()
            created.start()
            player = created
        } catch (e: java.io.IOException) {
            created.release()
            speaking(false)
        } catch (e: RuntimeException) {
            created.release()
            speaking(false)
        }
    }

    fun stop() {
        player?.let {
            try {
                it.stop()
            } catch (e: IllegalStateException) {
                // Already finished.
            }
            it.release()
            speaking(false)
        }
        player = null
    }
}
