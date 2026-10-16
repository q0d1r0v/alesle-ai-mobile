import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:alesle_ai/features/home/data/agent_repository_impl.dart';
import 'package:alesle_ai/features/home/domain/agent_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Runs on a device/emulator against the REAL Kotlin side of the Pigeon
/// contract. Proves both halves of the generated bridge agree.
///
///   flutter test integration_test --dart-define-from-file=env/dev.json
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native status crosses the generated bridge', (_) async {
    final AgentStatusMessage message = await AgentHostApi().getStatus();
    // A freshly installed app has never been granted accessibility.
    expect(message.accessibilityEnabled, isFalse);
  });

  testWidgets('repository maps the native status into the domain', (_) async {
    final AgentStatus status = await AgentRepositoryImpl().status();
    expect(status.needsSetup, isTrue);
  });

  // The JVM unit tests cannot catch what only Android's own runtime rejects
  // (its regex engine differs): the safety rules must load on a device.
  testWidgets('the phone\'s safety rules run on the device', (_) async {
    final String refused = await AgentHostApi().debugExecute(
      '{"type":"intent","kind":"call","to":{"phone":"*880*1*50000#"}}',
    );
    expect(refused, contains('unsafe_number'));
    final String own = await AgentHostApi().debugExecute(
      '{"type":"launch_app","package":"com.alesle.ai"}',
    );
    expect(own, contains('own_app'));
  });
}
