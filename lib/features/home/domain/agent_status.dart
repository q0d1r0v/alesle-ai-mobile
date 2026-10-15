/// How the agent treats sensitive actions (sending, calling, deleting…).
///
/// A per-user setting, not a build property (docs/adr/0005 in alesle-ai-api).
/// Payments, purchases and deletions always ask, whatever the setting.
enum ExecutionPolicy {
  /// Default: every sensitive action waits for the user's confirmation.
  confirmSensitiveActions,

  /// The user switched confirmation off: a cancellable countdown instead.
  countdown,
}

/// Whether the device is ready to let the agent act.
final class AgentStatus {
  const AgentStatus({required this.accessibilityEnabled});

  final bool accessibilityEnabled;

  /// The user still has to switch the AccessibilityService on.
  bool get needsSetup => !accessibilityEnabled;
}
