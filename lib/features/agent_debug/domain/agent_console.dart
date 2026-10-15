/// What happened to the running task (mirrors the native StepEvent).
enum TaskEventKind { started, step, finished, stopped }

final class TaskEvent {
  const TaskEvent(this.kind, [this.text]);

  final TaskEventKind kind;
  final String? text;

  @override
  bool operator ==(Object other) =>
      other is TaskEvent && other.kind == kind && other.text == text;

  @override
  int get hashCode => Object.hash(kind, text);

  @override
  String toString() => text == null ? kind.name : '${kind.name}: $text';
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

  Future<TaskStart> startTask(String command);

  Future<void> stopTask();

  /// Task events while the console is open.
  Stream<TaskEvent> get events;
}
