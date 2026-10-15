import '../../../core/agent/agent_task.dart';

export '../../../core/agent/agent_task.dart';

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

  /// Task updates while the console is open.
  Stream<TaskUpdate> get events;
}
