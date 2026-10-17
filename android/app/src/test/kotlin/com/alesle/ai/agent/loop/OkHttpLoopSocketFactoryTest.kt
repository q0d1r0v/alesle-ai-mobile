package com.alesle.ai.agent.loop

import okhttp3.Response
import okhttp3.WebSocket
import okhttp3.WebSocketListener
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.concurrent.LinkedBlockingQueue
import java.util.concurrent.TimeUnit

class OkHttpLoopSocketFactoryTest {
    private val server = MockWebServer()
    private val events = LinkedBlockingQueue<String>()
    private val serverSide = LinkedBlockingQueue<WebSocket>()

    @After
    fun tearDown() = server.shutdown()

    private val listener =
        object : LoopSocketListener {
            override fun onOpen() {
                events += "open"
            }

            override fun onMessage(text: String) {
                events += "message:$text"
            }

            override fun onGone() {
                events += "gone"
            }

            override fun onUpgradeRequired() {
                events += "upgrade"
            }

            override fun onUnauthorized() {
                events += "unauthorized"
            }
        }

    private fun next(): String = events.poll(5, TimeUnit.SECONDS) ?: error("no event")

    @Test
    fun `sends the token, carries text both ways and reports the close`() {
        server.enqueue(
            MockResponse().withWebSocketUpgrade(
                object : WebSocketListener() {
                    override fun onOpen(
                        webSocket: WebSocket,
                        response: Response,
                    ) {
                        serverSide += webSocket
                        webSocket.send("""{"type":"observe"}""")
                    }

                    override fun onMessage(
                        webSocket: WebSocket,
                        text: String,
                    ) {
                        webSocket.send("echo:$text")
                    }
                },
            ),
        )
        server.start()
        val factory = OkHttpLoopSocketFactory(server.url("/v1/agent/ws").toString().replace("http", "ws"), "dev-token", appVersion = 7)
        val socket = factory.connect(listener)

        val upgrade = server.takeRequest(5, TimeUnit.SECONDS)!!
        assertEquals("Bearer dev-token", upgrade.getHeader("Authorization"))
        assertEquals("7", upgrade.getHeader("X-App-Version"))
        assertEquals("open", next())
        assertEquals("""message:{"type":"observe"}""", next())
        assertTrue(socket.send("hi"))
        assertEquals("message:echo:hi", next())

        serverSide.take().close(1000, "bye")
        assertEquals("gone", next())
        socket.close()
    }

    @Test
    fun `reports a refused token as such, and any other refusal as gone`() {
        server.enqueue(MockResponse().setResponseCode(401))
        server.enqueue(MockResponse().setResponseCode(503))
        server.start()
        OkHttpLoopSocketFactory(server.url("/v1/agent/ws").toString(), "bad", appVersion = 7).connect(listener)
        assertEquals("unauthorized", next())
        OkHttpLoopSocketFactory(server.url("/v1/voice/live").toString(), "ok", appVersion = 7).connect(listener)
        assertEquals("gone", next())
    }

    @Test
    fun `reports an outdated app as such`() {
        server.enqueue(MockResponse().setResponseCode(426))
        server.start()
        OkHttpLoopSocketFactory(server.url("/v1/agent/ws").toString(), "dev-token", appVersion = 1).connect(listener)
        assertEquals("upgrade", next())
    }

    @Test
    fun `derives the socket url from the API origin`() {
        assertEquals("ws://127.0.0.1:3000/v1/agent/ws", OkHttpLoopSocketFactory.socketUrl("http://127.0.0.1:3000"))
        assertEquals("wss://api.alesle.ai/v1/agent/ws", OkHttpLoopSocketFactory.socketUrl("https://api.alesle.ai/"))
        assertEquals("ws://127.0.0.1:3000/v1/voice/live", OkHttpLoopSocketFactory.socketUrl("http://127.0.0.1:3000", "/v1/voice/live"))
        assertThrows(IllegalArgumentException::class.java) { OkHttpLoopSocketFactory.socketUrl("ftp://x") }
    }
}
