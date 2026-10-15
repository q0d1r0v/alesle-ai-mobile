// Pigeon contract between Dart and the Kotlin agent runtime.
//
// Regenerate after editing:  dart run pigeon --input pigeons/agent_api.dart
// Generated files are committed; CI fails if they drift from this contract.
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/platform/generated/agent_api.g.dart',
    dartPackageName: 'alesle_ai',
    kotlinOut: 'android/app/src/main/kotlin/com/alesle/ai/agent/generated/AgentApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.alesle.ai.agent.generated'),
  ),
)
/// How much the agent may do without asking (docs/adr/0003 in alesle-ai-api).
enum ExecutionPolicyMessage {
  /// `play` flavor: every sensitive action waits for the user's confirmation.
  confirmSensitiveActions,

  /// `direct` flavor: acts on its own; sensitive actions show a cancellable countdown.
  autonomous,
}

class AgentStatusMessage {
  AgentStatusMessage({
    required this.accessibilityEnabled,
    required this.policy,
    required this.distribution,
  });

  /// Whether the user has switched on Alesle's AccessibilityService.
  final bool accessibilityEnabled;
  final ExecutionPolicyMessage policy;

  /// `play` or `direct`, from BuildConfig — the native source of truth.
  final String distribution;
}

@HostApi()
abstract class AgentHostApi {
  AgentStatusMessage getStatus();

  /// Opens the system Accessibility settings screen.
  void openAccessibilitySettings();
}
