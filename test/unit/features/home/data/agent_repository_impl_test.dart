import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:alesle_ai/features/home/data/agent_repository_impl.dart';
import 'package:alesle_ai/features/home/domain/agent_status.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAgentHostApi extends Mock implements AgentHostApi {}

void main() {
  late _MockAgentHostApi api;
  late AgentRepositoryImpl repository;

  setUp(() {
    api = _MockAgentHostApi();
    repository = AgentRepositoryImpl(api);
  });

  test('maps a play-build status', () async {
    when(api.getStatus).thenAnswer(
      (_) async => AgentStatusMessage(
        accessibilityEnabled: false,
        policy: ExecutionPolicyMessage.confirmSensitiveActions,
        distribution: 'play',
      ),
    );
    final AgentStatus status = await repository.status();
    expect(status.accessibilityEnabled, isFalse);
    expect(status.policy, ExecutionPolicy.confirmSensitiveActions);
    expect(status.distribution, 'play');
  });

  test('maps a direct-build status', () async {
    when(api.getStatus).thenAnswer(
      (_) async => AgentStatusMessage(
        accessibilityEnabled: true,
        policy: ExecutionPolicyMessage.autonomous,
        distribution: 'direct',
      ),
    );
    expect((await repository.status()).policy, ExecutionPolicy.autonomous);
  });

  test('opens accessibility settings through the host API', () async {
    when(api.openAccessibilitySettings).thenAnswer((_) async {});
    await repository.openAccessibilitySettings();
    verify(api.openAccessibilitySettings).called(1);
  });

  test('wraps platform errors in UnexpectedFailure', () async {
    when(api.getStatus).thenThrow(PlatformException(code: 'channel-error'));
    when(api.openAccessibilitySettings)
        .thenThrow(PlatformException(code: 'no-activity'));

    await expectLater(repository.status(), throwsA(isA<UnexpectedFailure>()));
    await expectLater(
      repository.openAccessibilitySettings(),
      throwsA(isA<UnexpectedFailure>()),
    );
  });

  test('defaults to the real Pigeon host API', () {
    expect(AgentRepositoryImpl(), isA<AgentRepositoryImpl>());
  });
}
