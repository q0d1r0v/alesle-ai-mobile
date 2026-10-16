/// Pure task types shared by every feature that runs or watches agent tasks.
library;

/// A command to run, with how the user wants sensitive steps handled.
final class TaskCommand {
  const TaskCommand({
    required this.text,
    required this.locale,
    required this.confirmSensitiveActions,
    this.handsFree = false,
  });

  final String text;

  /// BCP-47 tag the agent answers in.
  final String locale;
  final bool confirmSensitiveActions;

  /// Heard by hands-free listening: words not meant for Alesle end quietly
  /// as [notAddressed].
  final bool handsFree;
}

/// How a hands-free task ends when the words were not meant for Alesle.
const String notAddressed = 'not_addressed';

/// Whether a task started; [reason] is a snake_case code when it did not.
final class TaskStart {
  const TaskStart({required this.started, this.reason});

  final bool started;
  final String? reason;
}

enum TaskUpdateKind { started, step, finished }

/// How a finished task ended (alesle-ai-api docs/agent-protocol.md).
enum TaskOutcome { done, failed, cannot, stopped, interrupted }

/// What happened to the running task.
final class TaskUpdate {
  const TaskUpdate(this.kind, {this.text, this.status, this.reason});

  final TaskUpdateKind kind;

  /// The command (started), the step label (step) or the agent's reply (finished).
  final String? text;

  /// For finished: done, failed, cannot, stopped, interrupted.
  final String? status;

  /// For finished: snake_case code when not done.
  final String? reason;

  /// [status] as an outcome; an unknown status counts as failed.
  TaskOutcome? get outcome => kind != TaskUpdateKind.finished
      ? null
      : TaskOutcome.values.firstWhere(
          (TaskOutcome value) => value.name == status,
          orElse: () => TaskOutcome.failed,
        );

  @override
  bool operator ==(Object other) =>
      other is TaskUpdate &&
      other.kind == kind &&
      other.text == text &&
      other.status == status &&
      other.reason == reason;

  @override
  int get hashCode => Object.hash(kind, text, status, reason);

  @override
  String toString() {
    final String head = <String>[kind.name, ?status, ?reason].join(' ');
    return text == null ? head : '$head: $text';
  }
}
