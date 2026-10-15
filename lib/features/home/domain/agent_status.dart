/// How much the agent may do without asking. Mirrors the native
/// `ExecutionPolicy` (Kotlin); the device build is the source of truth.
enum ExecutionPolicy {
  /// Google Play build: every sensitive action waits for the user.
  confirmSensitiveActions,

  /// Direct (APK) build: acts on its own, with a cancellable countdown.
  autonomous,
}

/// Whether the device is ready to let the agent act.
final class AgentStatus {
  const AgentStatus({
    required this.accessibilityEnabled,
    required this.policy,
    required this.distribution,
  });

  final bool accessibilityEnabled;
  final ExecutionPolicy policy;
  final String distribution;

  /// The user still has to switch the AccessibilityService on.
  bool get needsSetup => !accessibilityEnabled;
}
