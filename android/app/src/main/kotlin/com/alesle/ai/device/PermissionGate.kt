package com.alesle.ai.device

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.core.content.edit
import com.alesle.ai.agent.generated.PermissionKind
import com.alesle.ai.agent.generated.PermissionState
import kotlinx.coroutines.CompletableDeferred

/**
 * Runtime permissions for onboarding (SOW 09 §2, steps 3–5). Android says
 * "permanently denied" only indirectly: asked before, denied, and no
 * rationale to show any more. "Asked before" is remembered here.
 */
class PermissionGate(
    private val context: Context,
    private val activity: () -> Activity?,
) {
    private val asked = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    private var pending: Pair<Int, CompletableDeferred<PermissionState>>? = null

    fun state(kind: PermissionKind): PermissionState {
        val permission = manifestPermission(kind) ?: return PermissionState.GRANTED
        if (ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED) return PermissionState.GRANTED
        val host = activity()
        val permanently =
            asked.getBoolean(permission, false) &&
                host != null &&
                !ActivityCompat.shouldShowRequestPermissionRationale(host, permission)
        return if (permanently) PermissionState.PERMANENTLY_DENIED else PermissionState.DENIED
    }

    suspend fun request(kind: PermissionKind): PermissionState {
        val permission = manifestPermission(kind) ?: return PermissionState.GRANTED
        if (state(kind) != PermissionState.DENIED) return state(kind)
        val host = activity() ?: return PermissionState.DENIED
        pending?.second?.complete(state(kind))
        val code = REQUEST_BASE + kind.ordinal
        val result = CompletableDeferred<PermissionState>()
        pending = code to result
        asked.edit { putBoolean(permission, true) }
        ActivityCompat.requestPermissions(host, arrayOf(permission), code)
        return result.await()
    }

    /** From `Activity.onRequestPermissionsResult`. */
    fun onResult(requestCode: Int) {
        val (code, result) = pending ?: return
        if (code != requestCode) return
        pending = null
        val kind = PermissionKind.entries[code - REQUEST_BASE]
        result.complete(state(kind))
    }

    companion object {
        private const val PREFS = "alesle_permissions"
        private const val REQUEST_BASE = 4_100

        /** Null: nothing to ask on this Android version (notifications before 13). */
        fun manifestPermission(kind: PermissionKind): String? =
            when (kind) {
                PermissionKind.MICROPHONE -> Manifest.permission.RECORD_AUDIO
                PermissionKind.CONTACTS -> Manifest.permission.READ_CONTACTS
                PermissionKind.NOTIFICATIONS ->
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) Manifest.permission.POST_NOTIFICATIONS else null
            }
    }
}
