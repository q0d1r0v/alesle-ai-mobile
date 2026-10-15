import '../../../core/agent/agent_task.dart';
import 'agent_status.dart';
import 'server_health.dart';

/// Backend reachability. Throws a `Failure` from core/errors on error.
abstract interface class HealthRepository {
  Future<ServerHealth> readiness();
}

/// The on-device agent runtime (Kotlin, via Pigeon).
abstract interface class AgentRepository {
  Future<AgentStatus> status();

  Future<void> openAccessibilitySettings();
}

/// Runs the user's commands on the agent (Kotlin loop + API). Throws a
/// `Failure` from core/errors when the platform call itself fails.
abstract interface class AssistantRepository {
  /// Refused with `not_signed_in` when there is no token yet.
  Future<TaskStart> start(TaskCommand command);

  Future<void> stop();

  /// Updates of the running task, while anyone listens.
  Stream<TaskUpdate> get updates;
}
