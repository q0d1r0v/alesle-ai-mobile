package com.alesle.ai.device

import android.media.AudioAttributes
import android.media.MediaPlayer

/** Plays the agent's spoken reply; one at a time, released when done. */
class AudioPlayer(
    private val newPlayer: () -> MediaPlayer = ::MediaPlayer,
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
                if (player === finished) player = null
            }
            created.prepare()
            created.start()
            player = created
        } catch (e: java.io.IOException) {
            created.release()
        } catch (e: RuntimeException) {
            created.release()
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
        }
        player = null
    }
}
