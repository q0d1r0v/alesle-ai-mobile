package com.alesle.ai.agent

import com.alesle.ai.agent.generated.ExecutionPolicyMessage
import org.junit.Assert.assertEquals
import org.junit.Test

class ExecutionPolicyTest {
    @Test
    fun `direct distribution is autonomous`() {
        assertEquals(ExecutionPolicy.AUTONOMOUS, ExecutionPolicy.forDistribution("direct"))
    }

    @Test
    fun `play distribution confirms sensitive actions`() {
        assertEquals(ExecutionPolicy.CONFIRM_SENSITIVE_ACTIONS, ExecutionPolicy.forDistribution("play"))
    }

    @Test
    fun `unknown or malformed distributions fail closed`() {
        listOf("", "Direct", "direct ", "debug", "autonomous").forEach {
            assertEquals(it, ExecutionPolicy.CONFIRM_SENSITIVE_ACTIONS, ExecutionPolicy.forDistribution(it))
        }
    }

    @Test
    fun `maps to the Pigeon message`() {
        assertEquals(ExecutionPolicyMessage.AUTONOMOUS, ExecutionPolicy.AUTONOMOUS.toMessage())
        assertEquals(
            ExecutionPolicyMessage.CONFIRM_SENSITIVE_ACTIONS,
            ExecutionPolicy.CONFIRM_SENSITIVE_ACTIONS.toMessage(),
        )
    }
}
