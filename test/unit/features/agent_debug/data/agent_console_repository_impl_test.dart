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

void main() {
  late _MockAgentHostApi api;
  late List<AgentEventsApi?> registrations;
  late AgentConsoleRepositoryImpl repository;

  setUp(() {
    api = _MockAgentHostApi();
    registrations = <AgentEventsApi?>[];
    repository = AgentConsoleRepositoryImpl(
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

  test('starts and stops tasks', () async {
    when(() => api.startTask('salom')).thenAnswer(
      (_) async => StartTaskResult(started: false, reason: 'accessibility_off'),
    );
    when(api.stopTask).thenAnswer((_) async {});

    final TaskStart start = await repository.startTask('salom');
    expect(start.started, isFalse);
    expect(start.reason, 'accessibility_off');

    await repository.stopTask();
    verify(api.stopTask).called(1);
  });

  test('listens to native events only while someone listens', () async {
    final List<TaskEvent> seen = <TaskEvent>[];
    final subscription = repository.events.listen(seen.add);
    expect(registrations, <AgentEventsApi?>[repository]);

    repository
      ..onStepEvent(StepEvent(kind: StepEventKind.started, text: 'salom'))
      ..onStepEvent(StepEvent(kind: StepEventKind.step, text: 'Telegram'))
      ..onStepEvent(StepEvent(kind: StepEventKind.finished, text: 'done'))
      ..onStepEvent(StepEvent(kind: StepEventKind.stopped));
    await Future<void>.delayed(Duration.zero);

    expect(seen, const <TaskEvent>[
      TaskEvent(TaskEventKind.started, 'salom'),
      TaskEvent(TaskEventKind.step, 'Telegram'),
      TaskEvent(TaskEventKind.finished, 'done'),
      TaskEvent(TaskEventKind.stopped),
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
    await expectLater(repository.startTask('x'), failure);
    await expectLater(repository.stopTask(), failure);
  });

  test('defaults to the real Pigeon APIs', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      container.read(agentConsoleRepositoryProvider),
      isA<AgentConsoleRepositoryImpl>(),
    );
  });
}
