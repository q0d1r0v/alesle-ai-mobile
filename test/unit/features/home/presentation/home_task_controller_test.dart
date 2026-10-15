import 'package:alesle_ai/core/agent/agent_task.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:alesle_ai/features/home/presentation/home_task_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late FakeAssistantRepository assistant;
  late ProviderContainer container;

  const TaskCommand command = TaskCommand(
    text: '  Salom  ',
    locale: 'uz',
    confirmSensitiveActions: true,
  );

  setUp(() {
    assistant = FakeAssistantRepository();
    container = ProviderContainer(
      overrides: [assistantRepositoryProvider.overrideWithValue(assistant)],
    );
    addTearDown(container.dispose);
  });

  HomeTask state() => container.read(homeTaskProvider);
  HomeTaskController controller() => container.read(homeTaskProvider.notifier);

  Future<void> flush() => Future<void>.delayed(Duration.zero);

  test('starts idle and runs a trimmed command once', () async {
    expect(state(), isA<TaskIdle>());
    await controller().start(command);
    expect((state() as TaskRunning).command, 'Salom');
    await controller().start(command);
    expect(assistant.commands, hasLength(1));
  });

  test('ignores an empty command', () async {
    await controller().start(
      const TaskCommand(text: ' ', locale: 'uz', confirmSensitiveActions: true),
    );
    expect(state(), isA<TaskIdle>());
    expect(assistant.commands, isEmpty);
  });

  test('follows steps and the finish, counting steps', () async {
    await controller().start(command);
    assistant
      ..push(const TaskUpdate(TaskUpdateKind.started, text: 'Salom'))
      ..push(const TaskUpdate(TaskUpdateKind.step, text: 'A'))
      ..push(const TaskUpdate(TaskUpdateKind.step, text: 'B'));
    await flush();
    final TaskRunning running = state() as TaskRunning;
    expect(running.step, 'B');
    expect(running.steps, 2);

    assistant.push(
      const TaskUpdate(TaskUpdateKind.finished, text: 'OK', status: 'done'),
    );
    await flush();
    final TaskResult result = state() as TaskResult;
    expect(result.command, 'Salom');
    expect(result.outcome, TaskOutcome.done);
    expect(result.steps, 2);
    expect(result.isQuickAnswer, isFalse);

    controller().dismiss();
    expect(state(), isA<TaskIdle>());
  });

  test('picks up a task it did not start (e.g. from the console)', () async {
    container.read(homeTaskProvider);
    assistant.push(const TaskUpdate(TaskUpdateKind.started, text: 'Budilnik'));
    await flush();
    expect((state() as TaskRunning).command, 'Budilnik');

    controller().dismiss();
    assistant.push(const TaskUpdate(TaskUpdateKind.step, text: 'Soat'));
    await flush();
    expect((state() as TaskRunning).step, 'Soat');

    controller().dismiss();
    assistant.push(
      const TaskUpdate(
        TaskUpdateKind.finished,
        status: 'interrupted',
        reason: 'connection_lost',
      ),
    );
    await flush();
    final TaskResult result = state() as TaskResult;
    expect(result.command, '');
    expect(result.outcome, TaskOutcome.interrupted);
    expect(result.reason, 'connection_lost');
  });

  test('a done task without steps is a quick answer', () async {
    await controller().start(command);
    assistant.push(
      const TaskUpdate(
        TaskUpdateKind.finished,
        text: 'Toshkent',
        status: 'done',
      ),
    );
    await flush();
    expect((state() as TaskResult).isQuickAnswer, isTrue);
  });

  test('a refused or failed start ends as not done', () async {
    assistant.nextStart = const TaskStart(
      started: false,
      reason: 'accessibility_off',
    );
    await controller().start(command);
    expect((state() as TaskResult).reason, 'accessibility_off');

    controller().dismiss();
    assistant.failure = const NetworkFailure();
    await controller().start(command);
    expect((state() as TaskResult).outcome, TaskOutcome.failed);
  });

  test('stop goes to the repository and swallows a failure', () async {
    await controller().stop();
    assistant.failure = const NetworkFailure();
    await controller().stop();
    expect(assistant.stops, 2);
  });
}
