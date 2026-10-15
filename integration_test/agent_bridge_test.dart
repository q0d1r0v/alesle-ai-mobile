import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:alesle_ai/features/home/data/agent_repository_impl.dart';
import 'package:alesle_ai/features/home/domain/agent_status.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Runs on a device/emulator against the REAL Kotlin side of the Pigeon
/// contract. Proves both halves of the generated bridge agree and that the
/// native build's policy matches the Flutter flavor.
///
///   flutter test integration_test --flavor play  --dart-define-from-file=env/dev.json
///   flutter test integration_test --flavor direct --dart-define-from-file=env/dev.json
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native status reports the flavor this app was built with', (
    _,
  ) async {
    final AgentStatusMessage message = await AgentHostApi().getStatus();
    expect(message.distribution, appFlavor);
    expect(
      message.policy,
      appFlavor == 'direct'
          ? ExecutionPolicyMessage.autonomous
          : ExecutionPolicyMessage.confirmSensitiveActions,
    );
  });

  testWidgets('repository maps the native status into the domain', (_) async {
    final AgentStatus status = await AgentRepositoryImpl().status();
    // A freshly installed app has never been granted accessibility.
    expect(status.needsSetup, isTrue);
    expect(status.distribution, appFlavor);
  });
}
