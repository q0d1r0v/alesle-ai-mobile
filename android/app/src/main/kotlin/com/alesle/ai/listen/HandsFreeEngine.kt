package com.alesle.ai.listen

import java.util.concurrent.ConcurrentLinkedQueue

/** Where frames come from: the microphone in production. Blocking; one reader thread. */
interface PcmSource {
    /** Fills [frame]; the number of samples read, or a negative number when the source is gone. */
    fun read(frame: ShortArray): Int

    fun close()
}

/**
 * The always-on listening loop: reads frames, drops them while [quiet] says
 * so (muted, or Alesle itself is speaking — it must not hear itself), and
 * hands each utterance the detector cuts to [onUtterance]. Audio is never
 * kept beyond the current utterance.
 */
class HandsFreeEngine(
    private val openSource: () -> PcmSource?,
    private val quiet: () -> Boolean,
    private val onUtterance: (ShortArray) -> Unit,
    private val onSourceLost: () -> Unit = {},
    private val tuning: VoiceActivityDetector.Tuning = VoiceActivityDetector.Tuning(),
    /** Live voice: speech as it is heard (see [VoiceActivityDetector.SpeechStream]). */
    private val stream: VoiceActivityDetector.SpeechStream? = null,
    private val strict: () -> Boolean = { false },
) {
    private val injected = ConcurrentLinkedQueue<ShortArray>()

    @Volatile
    private var running = false
    private var thread: Thread? = null

    val isRunning: Boolean get() = running

    /** False when the microphone could not be opened. */
    @Synchronized
    fun start(): Boolean {
        if (running) return true
        val source = openSource() ?: return false
        running = true
        thread =
            Thread({ loop(source) }, "alesle-listen").apply {
                isDaemon = true
                start()
            }
        return true
    }

    @Synchronized
    fun stop() {
        running = false
        thread?.interrupt()
        thread = null
        injected.clear()
    }

    /**
     * Debug builds: plays [pcm] into the detector in place of the microphone,
     * in real time, so a test can speak to the phone without a person.
     */
    fun inject(pcm: ShortArray) {
        var at = 0
        while (at < pcm.size) {
            val end = minOf(at + VoiceActivityDetector.FRAME_SAMPLES, pcm.size)
            injected.add(pcm.copyOfRange(at, end).copyOf(VoiceActivityDetector.FRAME_SAMPLES))
            at = end
        }
    }

    private fun loop(source: PcmSource) {
        val detector = VoiceActivityDetector(onUtterance, tuning, stream, strict)
        val frame = ShortArray(VoiceActivityDetector.FRAME_SAMPLES)
        try {
            while (running) {
                val read = source.read(frame)
                if (read < 0) {
                    if (running) onSourceLost()
                    return
                }
                val next = injected.poll() ?: frame.copyOf()
                if (quiet()) {
                    detector.reset()
                    continue
                }
                detector.accept(next)
            }
        } finally {
            source.close()
        }
    }
}
