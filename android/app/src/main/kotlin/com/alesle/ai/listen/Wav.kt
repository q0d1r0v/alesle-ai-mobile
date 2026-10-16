package com.alesle.ai.listen

import java.io.File
import java.io.RandomAccessFile
import java.nio.ByteBuffer
import java.nio.ByteOrder

/** 16-bit mono PCM in a RIFF/WAVE file: what the speech endpoint takes as `audio/wav`. */
object Wav {
    private const val HEADER_BYTES = 44

    fun write(
        file: File,
        pcm: ShortArray,
        sampleRate: Int = VoiceActivityDetector.SAMPLE_RATE,
    ) {
        val data = pcm.size * 2
        val buffer = ByteBuffer.allocate(HEADER_BYTES + data).order(ByteOrder.LITTLE_ENDIAN)
        buffer.put("RIFF".toByteArray(Charsets.US_ASCII))
        buffer.putInt(36 + data)
        buffer.put("WAVE".toByteArray(Charsets.US_ASCII))
        buffer.put("fmt ".toByteArray(Charsets.US_ASCII))
        buffer.putInt(16) // PCM header size
        buffer.putShort(1) // PCM
        buffer.putShort(1) // mono
        buffer.putInt(sampleRate)
        buffer.putInt(sampleRate * 2) // byte rate
        buffer.putShort(2) // block align
        buffer.putShort(16) // bits per sample
        buffer.put("data".toByteArray(Charsets.US_ASCII))
        buffer.putInt(data)
        for (sample in pcm) buffer.putShort(sample)
        file.writeBytes(buffer.array())
    }

    /** The samples of a 16-bit mono WAV (the debug receiver injects these); null when it is not one. */
    fun read(file: File): ShortArray? {
        RandomAccessFile(file, "r").use { input ->
            val bytes = ByteArray(input.length().toInt())
            input.readFully(bytes)
            val buffer = ByteBuffer.wrap(bytes).order(ByteOrder.LITTLE_ENDIAN)
            if (bytes.size < HEADER_BYTES || String(bytes, 0, 4, Charsets.US_ASCII) != "RIFF") return null
            // Walk the chunks: "fmt " then "data", with anything in between skipped.
            var at = 12
            var bits = 0
            var channels = 0
            while (at + 8 <= bytes.size) {
                val id = String(bytes, at, 4, Charsets.US_ASCII)
                val size = buffer.getInt(at + 4)
                if (id == "fmt ") {
                    channels = buffer.getShort(at + 10).toInt()
                    bits = buffer.getShort(at + 22).toInt()
                }
                if (id == "data") {
                    if (bits != 16 || channels != 1) return null
                    val count = minOf(size, bytes.size - at - 8) / 2
                    return ShortArray(count) { buffer.getShort(at + 8 + it * 2) }
                }
                at += 8 + size + (size and 1)
            }
            return null
        }
    }
}
