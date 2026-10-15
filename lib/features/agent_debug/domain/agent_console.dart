/// What happened to the running task (mirrors the native StepEvent).
enum TaskEventKind { started, step, finished }

final class TaskEvent {
  const TaskEvent(this.kind, {this.text, this.status, this.reason});

  final TaskEventKind kind;

  /// The command (started), the step label (step) or the agent's reply (finished).
  final String? text;

  /// For finished: done, failed, cannot, stopped, interrupted.
  final String? status;

  /// For finished: snake_case code when not done.
  final String? reason;

  @override
  bool operator ==(Object other) =>
      other is TaskEvent &&
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

/// A command to run, with how the user wants sensitive steps handled.
final class TaskCommand {
  const TaskCommand({
    required this.text,
    required this.locale,
    required this.confirmSensitiveActions,
  });

  final String text;

  /// BCP-47 tag the agent answers in.
  final String locale;
  final bool confirmSensitiveActions;
}

/// Whether a task started; [reason] is a snake_case code when it did not.
final class TaskStart {
  const TaskStart({required this.started, this.reason});

  final bool started;
  final String? reason;
}

/// Developer console to the native agent runtime (debug builds only).
///
/// Snapshots and action results are raw JSON strings: this is a tool for
/// looking at exactly what the runtime produces. Throws a `Failure` from
/// core/errors on error.
abstract interface class AgentConsoleRepository {
  /// The current screen as snapshot JSON, with `captureMs`.
  Future<String> snapshot();

  /// Runs one action (ActionJson wire format); returns the result JSON.
  Future<String> execute(String actionJson);

  /// Refused with `not_signed_in` when the build has no token yet.
  Future<TaskStart> startTask(TaskCommand command);

  Future<void> stopTask();

  /// Task events while the console is open.
  Stream<TaskEvent> get events;
}
