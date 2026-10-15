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
class AgentStatusMessage {
  AgentStatusMessage({required this.accessibilityEnabled});

  /// Whether the user has switched on Alesle's AccessibilityService.
  final bool accessibilityEnabled;
}

@HostApi()
abstract class AgentHostApi {
  AgentStatusMessage getStatus();

  /// Opens the system Accessibility settings screen.
  void openAccessibilitySettings();
}
