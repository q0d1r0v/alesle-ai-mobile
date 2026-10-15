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
        val factory = OkHttpLoopSocketFactory(server.url("/v1/agent/ws").toString().replace("http", "ws"), "dev-token")
        val socket = factory.connect(listener)

        assertEquals("Bearer dev-token", server.takeRequest(5, TimeUnit.SECONDS)!!.getHeader("Authorization"))
        assertEquals("open", next())
        assertEquals("""message:{"type":"observe"}""", next())
        assertTrue(socket.send("hi"))
        assertEquals("message:echo:hi", next())

        serverSide.take().close(1000, "bye")
        assertEquals("gone", next())
        socket.close()
    }

    @Test
    fun `reports a refused upgrade as gone`() {
        server.enqueue(MockResponse().setResponseCode(401))
        server.start()
        OkHttpLoopSocketFactory(server.url("/v1/agent/ws").toString(), "bad").connect(listener)
        assertEquals("gone", next())
    }

    @Test
    fun `derives the socket url from the API origin`() {
        assertEquals("ws://127.0.0.1:3000/v1/agent/ws", OkHttpLoopSocketFactory.socketUrl("http://127.0.0.1:3000"))
        assertEquals("wss://api.alesle.ai/v1/agent/ws", OkHttpLoopSocketFactory.socketUrl("https://api.alesle.ai/"))
        assertThrows(IllegalArgumentException::class.java) { OkHttpLoopSocketFactory.socketUrl("ftp://x") }
    }
}
