import 'dart:async';

import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:alesle_ai/features/agent_debug/data/agent_console_repository_impl.dart';
import 'package:alesle_ai/features/agent_debug/data/agent_debug_data_providers.dart';
import 'package:alesle_ai/features/agent_debug/domain/agent_console.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAgentHostApi extends Mock implements AgentHostApi {}

const AppConfig _config = AppConfig(
  environment: AppEnvironment.dev,
  apiBaseUrl: 'http://127.0.0.1:3000',
  devAuthToken: 'dev-token',
);

const TaskCommand _command = TaskCommand(
  text: 'Budilnik 7:30',
  locale: 'uz',
  confirmSensitiveActions: false,
);

void main() {
  late _MockAgentHostApi api;
  late List<AgentEventsApi?> registrations;
  late AgentConsoleRepositoryImpl repository;

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
    registrations = <AgentEventsApi?>[];
    repository = AgentConsoleRepositoryImpl(
      config: _config,
      api: api,
      registerEvents: registrations.add,
    );
  });

  test('passes snapshots and action results through as JSON', () async {
    when(api.debugSnapshot).thenAnswer((_) async => '{"captureMs":9}');
    when(() => api.debugExecute('{"type":"back"}'))
        .thenAnswer((_) async => '{"status":"ok"}');

    expect(await repository.snapshot(), '{"captureMs":9}');
    expect(await repository.execute('{"type":"back"}'), '{"status":"ok"}');
  });

  test('starts a task with the server, token, locale and policy', () async {
    when(() => api.startTask(any())).thenAnswer(
      (_) async => StartTaskResult(started: false, reason: 'accessibility_off'),
    );
    when(api.stopTask).thenAnswer((_) async {});

    final TaskStart start = await repository.startTask(_command);
    expect(start.started, isFalse);
    expect(start.reason, 'accessibility_off');

    final TaskRequest sent =
        verify(() => api.startTask(captureAny())).captured.single
            as TaskRequest;
    expect(sent.command, 'Budilnik 7:30');
    expect(sent.apiBaseUrl, 'http://127.0.0.1:3000');
    expect(sent.accessToken, 'dev-token');
    expect(sent.locale, 'uz');
    expect(sent.confirmEverySensitiveAction, isFalse);

    await repository.stopTask();
    verify(api.stopTask).called(1);
  });

  test('refuses to start without a token', () async {
    final AgentConsoleRepositoryImpl signedOut = AgentConsoleRepositoryImpl(
      config: const AppConfig(
        environment: AppEnvironment.dev,
        apiBaseUrl: 'http://127.0.0.1:3000',
      ),
      api: api,
      registerEvents: registrations.add,
    );
    final TaskStart start = await signedOut.startTask(_command);
    expect(start.started, isFalse);
    expect(start.reason, 'not_signed_in');
    verifyNever(() => api.startTask(any()));
  });

  test('listens to native events only while someone listens', () async {
    final List<TaskEvent> seen = <TaskEvent>[];
    final StreamSubscription<TaskEvent> subscription = repository.events.listen(
      seen.add,
    );
    expect(registrations, <AgentEventsApi?>[repository]);

    repository
      ..onStepEvent(StepEvent(kind: StepEventKind.started, text: 'salom'))
      ..onStepEvent(StepEvent(kind: StepEventKind.step, text: 'Telegram'))
      ..onStepEvent(
        StepEvent(kind: StepEventKind.finished, text: 'Done', status: 'done'),
      )
      ..onStepEvent(
        StepEvent(
          kind: StepEventKind.finished,
          status: 'interrupted',
          reason: 'connection_lost',
        ),
      );
    await Future<void>.delayed(Duration.zero);

    expect(seen, const <TaskEvent>[
      TaskEvent(TaskEventKind.started, text: 'salom'),
      TaskEvent(TaskEventKind.step, text: 'Telegram'),
      TaskEvent(TaskEventKind.finished, text: 'Done', status: 'done'),
      TaskEvent(
        TaskEventKind.finished,
        status: 'interrupted',
        reason: 'connection_lost',
      ),
    ]);

    await subscription.cancel();
    expect(registrations, <AgentEventsApi?>[repository, null]);
  });

  test('wraps platform errors in UnexpectedFailure', () async {
    final PlatformException debugOnly = PlatformException(code: 'debug_only');
    when(api.debugSnapshot).thenThrow(debugOnly);
    when(() => api.debugExecute(any())).thenThrow(debugOnly);
    when(() => api.startTask(any())).thenThrow(debugOnly);
    when(api.stopTask).thenThrow(debugOnly);

    final Matcher failure = throwsA(isA<UnexpectedFailure>());
    await expectLater(repository.snapshot(), failure);
    await expectLater(repository.execute('{}'), failure);
    await expectLater(repository.startTask(_command), failure);
    await expectLater(repository.stopTask(), failure);
  });

  test('is built from the app config', () {
    final ProviderContainer container = ProviderContainer(
      overrides: [appConfigProvider.overrideWithValue(_config)],
    );
    addTearDown(container.dispose);
    expect(
      container.read(agentConsoleRepositoryProvider),
      isA<AgentConsoleRepositoryImpl>(),
    );
  });
}
