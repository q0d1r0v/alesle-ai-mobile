import 'package:alesle_ai/features/home/domain/agent_status.dart';
import 'package:alesle_ai/features/home/domain/server_health.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ServerHealth.isReady', () {
    test('is true only when every dependency is up', () {
      expect(
        const ServerHealth(
          dependencies: <String, String>{'database': 'up', 'redis': 'up'},
        ).isReady,
        isTrue,
      );
      expect(
        const ServerHealth(
          dependencies: <String, String>{'database': 'up', 'redis': 'down'},
        ).isReady,
        isFalse,
      );
    });

    test('is false when the server reports no dependencies at all', () {
      expect(
        const ServerHealth(dependencies: <String, String>{}).isReady,
        isFalse,
      );
    });
  });

  group('AgentStatus.needsSetup', () {
    test('follows the accessibility switch', () {
      const AgentStatus off = AgentStatus(accessibilityEnabled: false);
      const AgentStatus on = AgentStatus(accessibilityEnabled: true);
      expect(off.needsSetup, isTrue);
      expect(on.needsSetup, isFalse);
    });
  });
}
