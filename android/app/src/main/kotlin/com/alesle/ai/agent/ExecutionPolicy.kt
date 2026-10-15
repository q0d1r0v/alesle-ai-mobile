package com.alesle.ai.agent

import com.alesle.ai.agent.generated.ExecutionPolicyMessage

/**
 * How much the agent may do without asking. Derived from the build's
 * distribution, never from user input or the server.
 */
enum class ExecutionPolicy {
    /** Google Play build: every sensitive action waits for the user. */
    CONFIRM_SENSITIVE_ACTIONS,

    /** Direct (APK) build: acts on its own; sensitive actions show a cancellable countdown. */
    AUTONOMOUS,
    ;

    fun toMessage(): ExecutionPolicyMessage =
        when (this) {
            CONFIRM_SENSITIVE_ACTIONS -> ExecutionPolicyMessage.CONFIRM_SENSITIVE_ACTIONS
            AUTONOMOUS -> ExecutionPolicyMessage.AUTONOMOUS
        }

    companion object {
        /**
         * Fails closed: any distribution other than exactly "direct" gets the
         * restrictive policy, so a misconfigured build can never become autonomous.
         */
        fun forDistribution(distribution: String): ExecutionPolicy = if (distribution == "direct") AUTONOMOUS else CONFIRM_SENSITIVE_ACTIONS
    }
}
