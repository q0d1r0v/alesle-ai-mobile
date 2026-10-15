import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/agent/agent_task.dart';
import '../../../core/errors/failure.dart';
import '../data/home_data_providers.dart';
import '../domain/home_repositories.dart';

/// What the home screen shows about the current command.
sealed class HomeTask {
  const HomeTask();
}

final class TaskIdle extends HomeTask {
  const TaskIdle();
}

final class TaskRunning extends HomeTask {
  const TaskRunning({required this.command, this.step, this.steps = 0});

  final String command;

  /// What the agent is doing now ("Opening Telegram"); null before the first step.
  final String? step;
  final int steps;
}

final class TaskResult extends HomeTask {
  const TaskResult({
    required this.command,
    required this.outcome,
    this.reply,
    this.reason,
    this.steps = 0,
  });

  final String command;
  final TaskOutcome outcome;

  /// The agent's own words, in the user's language.
  final String? reply;

  /// snake_case code when not done.
  final String? reason;

  /// Steps it took; a done task with none was a quick answer.
  final int steps;

  bool get isQuickAnswer =>
      outcome == TaskOutcome.done && steps == 0 && reply != null;
}

/// Starts, follows and stops the user's command.
class HomeTaskController extends Notifier<HomeTask> {
  StreamSubscription<TaskUpdate>? _subscription;

  AssistantRepository get _repository => ref.read(assistantRepositoryProvider);

  @override
  HomeTask build() {
    _subscription = ref.watch(assistantRepositoryProvider).updates.listen(_on);
    ref.onDispose(() => unawaited(_subscription?.cancel()));
    return const TaskIdle();
  }

  Future<void> start(TaskCommand command) async {
    final String text = command.text.trim();
    if (text.isEmpty || state is TaskRunning) return;
    state = TaskRunning(command: text);
    try {
      final TaskStart start = await _repository.start(command);
      if (!start.started) {
        state = TaskResult(
          command: text,
          outcome: TaskOutcome.failed,
          reason: start.reason,
        );
      }
    } on Failure {
      state = TaskResult(command: text, outcome: TaskOutcome.failed);
    }
  }

  Future<void> stop() async {
    try {
      await _repository.stop();
    } on Failure {
      // Nothing was running, or the platform is gone: the update stream decides.
    }
  }

  void dismiss() => state = const TaskIdle();

  void _on(TaskUpdate update) {
    final HomeTask current = state;
    switch (update.kind) {
      case TaskUpdateKind.started:
        if (current is! TaskRunning) {
          state = TaskRunning(command: update.text ?? '');
        }
      case TaskUpdateKind.step:
        final TaskRunning running = current is TaskRunning
            ? current
            : const TaskRunning(command: '');
        state = TaskRunning(
          command: running.command,
          step: update.text,
          steps: running.steps + 1,
        );
      case TaskUpdateKind.finished:
        state = TaskResult(
          command: current is TaskRunning ? current.command : '',
          outcome: update.outcome ?? TaskOutcome.failed,
          reply: update.text,
          reason: update.reason,
          steps: current is TaskRunning ? current.steps : 0,
        );
    }
  }
}

final NotifierProvider<HomeTaskController, HomeTask> homeTaskProvider =
    NotifierProvider<HomeTaskController, HomeTask>(HomeTaskController.new);
