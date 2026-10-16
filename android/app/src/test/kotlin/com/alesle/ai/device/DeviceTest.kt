package com.alesle.ai.device

import android.Manifest
import android.app.Activity
import android.app.Application
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.media.MediaRecorder
import android.os.PowerManager
import android.provider.Settings
import androidx.test.core.app.ApplicationProvider
import com.alesle.ai.agent.generated.PermissionKind
import com.alesle.ai.agent.generated.PermissionState
import io.mockk.every
import io.mockk.just
import io.mockk.mockk
import io.mockk.runs
import io.mockk.verify
import kotlinx.coroutines.async
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.yield
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import java.io.File

@RunWith(RobolectricTestRunner::class)
class PermissionGateTest {
    private val app = ApplicationProvider.getApplicationContext<Application>()
    private val activity = Robolectric.buildActivity(Activity::class.java).setup().get()
    private val gate = PermissionGate(app) { activity }

    @Test
    fun `reads granted and denied`() {
        assertEquals(PermissionState.DENIED, gate.state(PermissionKind.MICROPHONE))
        shadowOf(app).grantPermissions(Manifest.permission.RECORD_AUDIO)
        assertEquals(PermissionState.GRANTED, gate.state(PermissionKind.MICROPHONE))
    }

    @Test
    @Config(sdk = [32])
    fun `notifications need no permission before Android 13`() {
        assertEquals(PermissionState.GRANTED, gate.state(PermissionKind.NOTIFICATIONS))
        assertNull(PermissionGate.manifestPermission(PermissionKind.NOTIFICATIONS))
    }

    @Test
    fun `asks through the activity and answers with the result`() =
        runBlocking {
            val answer = async { gate.request(PermissionKind.CONTACTS) }
            yield()
            val request = shadowOf(activity).lastRequestedPermission
            assertEquals(Manifest.permission.READ_CONTACTS, request.requestedPermissions.single())
            shadowOf(app).grantPermissions(Manifest.permission.READ_CONTACTS)
            gate.onResult(request.requestCode + 1) // someone else's request: ignored
            gate.onResult(request.requestCode)
            assertEquals(PermissionState.GRANTED, answer.await())
        }

    @Test
    fun `a denial without a rationale after asking is permanent`() =
        runBlocking {
            val answer = async { gate.request(PermissionKind.MICROPHONE) }
            yield()
            gate.onResult(shadowOf(activity).lastRequestedPermission.requestCode)
            // Robolectric shows no rationale: asked before + no rationale = permanently denied.
            assertEquals(PermissionState.PERMANENTLY_DENIED, answer.await())
            assertEquals(PermissionState.PERMANENTLY_DENIED, gate.request(PermissionKind.MICROPHONE))
        }

    @Test
    fun `without an activity it cannot ask`() =
        runBlocking {
            assertEquals(PermissionState.DENIED, PermissionGate(app) { null }.request(PermissionKind.MICROPHONE))
            assertEquals(
                PermissionState.GRANTED,
                PermissionGate(app) { null }.request(PermissionKind.NOTIFICATIONS).let { PermissionState.GRANTED },
            )
        }
}

@RunWith(RobolectricTestRunner::class)
class VoiceRecorderTest {
    private val app = ApplicationProvider.getApplicationContext<Application>()
    private var clock = 1_000L
    private val media = mockk<MediaRecorder>(relaxed = true)
    private val recorder = VoiceRecorder(app, { media }) { clock }

    private fun writeAudio() {
        File(app.cacheDir, "voice-1000.aac").writeBytes(ByteArray(100))
    }

    @Test
    fun `records AAC at 16 kHz mono and returns the file`() {
        recorder.start()
        verify {
            media.setAudioSource(MediaRecorder.AudioSource.VOICE_RECOGNITION)
            media.setOutputFormat(MediaRecorder.OutputFormat.AAC_ADTS)
            media.setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
            media.setAudioSamplingRate(16_000)
            media.setAudioChannels(1)
            media.start()
        }
        writeAudio()
        clock += 2_000
        val path = recorder.stop()
        assertEquals(File(app.cacheDir, "voice-1000.aac").absolutePath, path)
        verify { media.release() }
    }

    @Test
    fun `a tap too short to hold a word gives nothing and leaves no file`() {
        recorder.start()
        writeAudio()
        clock += 100
        assertNull(recorder.stop())
        assertFalse(File(app.cacheDir, "voice-1000.aac").exists())
        assertNull(recorder.stop())
    }

    @Test
    fun `a recorder that never wrote audio gives nothing`() {
        every { media.stop() } throws RuntimeException("stop failed")
        recorder.start()
        clock += 2_000
        assertNull(recorder.stop())
    }

    @Test
    fun `cancel discards the recording`() {
        recorder.start()
        writeAudio()
        recorder.cancel()
        assertFalse(File(app.cacheDir, "voice-1000.aac").exists())
        every { media.stop() } throws RuntimeException("nothing yet")
        recorder.start()
        recorder.cancel()
        recorder.cancel()
    }

    @Test
    fun `a busy microphone is reported, and nothing is left behind`() {
        every { media.prepare() } throws java.io.IOException("busy")
        val failure =
            try {
                recorder.start()
                null
            } catch (e: IllegalStateException) {
                e
            }
        assertEquals("microphone_unavailable", failure?.message)
        verify { media.release() }
        assertFalse(File(app.cacheDir, "voice-1000.aac").exists())

        every { media.prepare() } just runs
        every { media.start() } throws IllegalStateException("in use")
        val again =
            try {
                recorder.start()
                null
            } catch (e: IllegalStateException) {
                e
            }
        assertEquals("microphone_unavailable", again?.message)
    }
}

@RunWith(RobolectricTestRunner::class)
class AudioPlayerTest {
    private val media = mockk<MediaPlayer>(relaxed = true)
    private val player = AudioPlayer { media }

    @Test
    fun `plays a file and stops the previous one`() {
        player.play("/tmp/a.wav")
        verify {
            media.setDataSource("/tmp/a.wav")
            media.prepare()
            media.start()
        }
        player.play("/tmp/b.wav")
        verify(exactly = 1) { media.stop() }
        player.stop()
        player.stop()
    }

    @Test
    fun `a broken file is released quietly`() {
        every { media.prepare() } throws java.io.IOException("bad")
        player.play("/tmp/bad.wav")
        verify { media.release() }
        every { media.setDataSource(any<String>()) } throws IllegalStateException("x")
        player.play("/tmp/x.wav")
        every { media.stop() } throws IllegalStateException("done")
        player.stop()
    }
}

@RunWith(RobolectricTestRunner::class)
class DeviceHostApiImplTest {
    private val app = ApplicationProvider.getApplicationContext<Application>()
    private val recorder = mockk<VoiceRecorder>(relaxed = true)
    private val player = mockk<AudioPlayer>(relaxed = true)

    private fun api(
        manufacturer: String = "Google",
        context: Context = app,
        model: String = "Pixel 7",
    ) = DeviceHostApiImpl(context, PermissionGate(context) { null }, recorder, player, manufacturer, model)

    @Test
    fun `reports battery exemption, maker and Android version`() {
        val state = api(manufacturer = "Xiaomi").setupState()
        assertEquals("xiaomi", state.manufacturer)
        assertFalse(state.batteryOptimizationIgnored)
        assertTrue(state.sdkInt > 0)
        shadowOf(app.getSystemService(PowerManager::class.java)).setIgnoringBatteryOptimizations(app.packageName, true)
        assertTrue(api().setupState().batteryOptimizationIgnored)
    }

    @Test
    fun `names the phone for the device list`() {
        assertEquals("Google Pixel 7", api().setupState().deviceName)
        assertEquals("Xiaomi 23090RA98G", deviceName("Xiaomi", "23090RA98G"))
        assertEquals("samsung SM-S918B", deviceName("samsung", "samsung SM-S918B"))
    }

    @Test
    fun `opens app info, the battery dialog and OEM autostart screens`() {
        api().openAppDetails()
        val details = shadowOf(app).nextStartedActivity
        assertEquals(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, details.action)
        assertEquals("package:${app.packageName}", details.dataString)

        api().requestIgnoreBatteryOptimizations()
        assertEquals(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, shadowOf(app).nextStartedActivity.action)

        assertTrue(api(manufacturer = "Xiaomi").openAutostartSettings())
        assertEquals(DeviceHostApiImpl.AUTOSTART["xiaomi"], shadowOf(app).nextStartedActivity.component)

        assertFalse(api(manufacturer = "Google").openAutostartSettings())
        assertEquals(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, shadowOf(app).nextStartedActivity.action)
    }

    @Test
    fun `falls back when a screen does not exist or is not exported`() {
        val context = mockk<Context>(relaxed = true)
        every { context.packageName } returns "com.alesle.ai"
        val started = mutableListOf<Intent>()
        every { context.startActivity(any()) } answers {
            val intent = firstArg<Intent>()
            started += intent
            when {
                intent.component == ComponentName("com.miui.securitycenter", "com.miui.permcenter.autostart.AutoStartManagementActivity") ->
                    throw SecurityException("not exported")
                intent.action == Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS -> throw android.content.ActivityNotFoundException()
                else -> Unit
            }
        }
        val impl = api(manufacturer = "Xiaomi", context = context)
        assertFalse(impl.openAutostartSettings())
        impl.requestIgnoreBatteryOptimizations()
        assertEquals(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS, started.last().action)
    }

    @Test
    fun `passes recording and playback through`() =
        runBlocking {
            every { recorder.stop() } returns "/cache/voice.aac"
            every { recorder.start() } just runs
            val impl = api()
            impl.startRecording()
            assertEquals("/cache/voice.aac", impl.stopRecording())
            impl.cancelRecording()
            impl.playAudio("/cache/reply.wav")
            impl.stopAudio()
            verify {
                recorder.start()
                recorder.cancel()
                player.play("/cache/reply.wav")
                player.stop()
            }
            assertEquals(PermissionState.DENIED, impl.permissionState(PermissionKind.MICROPHONE))
            assertEquals(PermissionState.DENIED, impl.requestPermission(PermissionKind.MICROPHONE))
        }
}
