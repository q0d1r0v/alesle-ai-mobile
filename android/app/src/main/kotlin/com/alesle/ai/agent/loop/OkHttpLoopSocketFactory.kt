package com.alesle.ai.agent.loop

import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import java.util.concurrent.TimeUnit

/** `/v1/agent/ws` over OkHttp; the bearer token goes in the upgrade request. */
class OkHttpLoopSocketFactory(
    private val url: String,
    private val token: String,
    /** This build's versionCode: outdated apps are refused with 426 (EC-15). */
    private val appVersion: Long,
    private val client: OkHttpClient = DEFAULT_CLIENT,
) : LoopSocketFactory {
    override fun connect(listener: LoopSocketListener): LoopSocket {
        val request =
            Request
                .Builder()
                .url(url)
                .header("Authorization", "Bearer $token")
                .header(APP_VERSION_HEADER, appVersion.toString())
                .build()
        val socket =
            client.newWebSocket(
                request,
                object : WebSocketListener() {
                    override fun onOpen(
                        webSocket: WebSocket,
                        response: Response,
                    ) = listener.onOpen()

                    override fun onMessage(
                        webSocket: WebSocket,
                        text: String,
                    ) = listener.onMessage(text)

                    override fun onClosing(
                        webSocket: WebSocket,
                        code: Int,
                        reason: String,
                    ) {
                        webSocket.close(NORMAL_CLOSURE, null)
                    }

                    override fun onClosed(
                        webSocket: WebSocket,
                        code: Int,
                        reason: String,
                    ) = listener.onGone()

                    override fun onFailure(
                        webSocket: WebSocket,
                        t: Throwable,
                        response: Response?,
                    ) = if (response?.code == UPGRADE_REQUIRED) listener.onUpgradeRequired() else listener.onGone()
                },
            )
        return object : LoopSocket {
            override fun send(text: String): Boolean = socket.send(text)

            override fun close() {
                socket.close(NORMAL_CLOSURE, null)
            }
        }
    }

    companion object {
        const val NORMAL_CLOSURE = 1000
        const val UPGRADE_REQUIRED = 426
        const val APP_VERSION_HEADER = "X-App-Version"
        const val PATH = "/v1/agent/ws"

        /** Pings keep NAT mappings open and notice a dead link within ~20 s. */
        val DEFAULT_CLIENT: OkHttpClient =
            OkHttpClient
                .Builder()
                .pingInterval(15, TimeUnit.SECONDS)
                .connectTimeout(10, TimeUnit.SECONDS)
                .build()

        /** `http://host:3000` → `ws://host:3000/v1/agent/ws` (https → wss). */
        fun socketUrl(apiBaseUrl: String): String {
            val base = apiBaseUrl.trimEnd('/')
            val scheme =
                when {
                    base.startsWith("https://") -> "wss://" to "https://"
                    base.startsWith("http://") -> "ws://" to "http://"
                    else -> throw IllegalArgumentException("API base URL must be http(s)")
                }
            return scheme.first + base.removePrefix(scheme.second) + PATH
        }
    }
}
