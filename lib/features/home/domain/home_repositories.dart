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
