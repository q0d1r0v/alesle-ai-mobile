import 'dart:async';

import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/agent/agent_task.dart';
import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/platform/agent_events_bridge.dart';
import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:alesle_ai/features/home/data/assistant_repository_impl.dart';
import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fakes.dart';

class _MockAgentHostApi extends Mock implements AgentHostApi {}

const AppConfig _config = AppConfig(
  environment: AppEnvironment.dev,
  apiBaseUrl: 'http://127.0.0.1:3000',
);

const TaskCommand _command = TaskCommand(
  text: 'Budilnik 7:30',
  locale: 'ru',
  confirmSensitiveActions: true,
);

void main() {
  late _MockAgentHostApi api;
  late AgentEventsBridge bridge;
  late FakeTokens tokens;
  late AssistantRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(
      TaskRequest(
        command: '',
        apiBaseUrl: '',
        accessToken: '',
        locale: '',
        confirmEverySensitiveAction: true,
      ),
    );
  });

  setUp(() {
    api = _MockAgentHostApi();
    bridge = AgentEventsBridge(register: (_) {});
    tokens = FakeTokens();
    repository = AssistantRepositoryImpl(
      config: _config,
      tokens: tokens,
      bridge: bridge,
      api: api,
    );
  });

  test('starts with the server, token, locale and policy', () async {
    when(() => api.startTask(any()))
        .thenAnswer((_) async => StartTaskResult(started: true));
    final TaskStart start = await repository.start(_command);
    expect(start.started, isTrue);
    final TaskRequest sent =
        verify(() => api.startTask(captureAny())).captured.single
            as TaskRequest;
    expect(sent.command, 'Budilnik 7:30');
    expect(sent.apiBaseUrl, 'http://127.0.0.1:3000');
    expect(sent.accessToken, 'access-token');
    // Good for longer than a whole task.
    expect(tokens.margins.single, const Duration(minutes: 5));
    expect(sent.locale, 'ru');
    expect(sent.confirmEverySensitiveAction, isTrue);
    expect(sent.handsFree, isFalse);

    await repository.start(
      const TaskCommand(
        text: 'Soat',
        locale: 'uz',
        confirmSensitiveActions: true,
        handsFree: true,
      ),
    );
    final TaskRequest heard =
        verify(() => api.startTask(captureAny())).captured.single
            as TaskRequest;
    expect(heard.handsFree, isTrue);
  });

  test('refuses without a token', () async {
    final AssistantRepositoryImpl signedOut = AssistantRepositoryImpl(
      config: _config,
      tokens: FakeTokens(null),
      bridge: bridge,
      api: api,
    );
    expect((await signedOut.start(_command)).reason, 'not_signed_in');
    verifyNever(() => api.startTask(any()));
  });

  test('stops, and wraps platform errors in UnexpectedFailure', () async {
    when(api.stopTask).thenAnswer((_) async {});
    await repository.stop();
    verify(api.stopTask).called(1);

    when(() => api.startTask(any())).thenThrow(PlatformException(code: 'x'));
    when(api.stopTask).thenThrow(PlatformException(code: 'x'));
    await expectLater(
      repository.start(_command),
      throwsA(isA<UnexpectedFailure>()),
    );
    await expectLater(repository.stop(), throwsA(isA<UnexpectedFailure>()));
  });

  test('passes what the user said to the running task', () async {
    when(() => api.amendTask('buni ham qil')).thenAnswer((_) async => true);
    when(() => api.amendTask('x')).thenAnswer((_) async => false);
    expect(await repository.amend('buni ham qil'), isTrue);
    expect(await repository.amend('x'), isFalse);
    when(() => api.amendTask('y')).thenThrow(PlatformException(code: 'x'));
    await expectLater(repository.amend('y'), throwsA(isA<UnexpectedFailure>()));
  });

  test('updates come from the shared bridge', () async {
    final List<TaskUpdate> seen = <TaskUpdate>[];
    final StreamSubscription<TaskUpdate> sub = repository.updates.listen(
      seen.add,
    );
    bridge.onStepEvent(StepEvent(kind: StepEventKind.step, text: 'Soat'));
    await Future<void>.delayed(Duration.zero);
    expect(seen.single.text, 'Soat');
    await sub.cancel();
  });

  test('is built from the app config and the bridge', () {
    final ProviderContainer container = ProviderContainer(
      overrides: [appConfigProvider.overrideWithValue(_config)],
    );
    addTearDown(container.dispose);
    expect(
      container.read(assistantRepositoryProvider),
      isA<AssistantRepositoryImpl>(),
    );
  });
}
