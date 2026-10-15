import 'dart:async';

import 'package:alesle_ai/features/home/domain/agent_status.dart';
import 'package:alesle_ai/features/home/domain/home_repositories.dart';
import 'package:alesle_ai/features/home/domain/server_health.dart';

/// Hand-written fakes for widget tests: they keep call counts and let a test
/// hold a future open to observe the loading state.
final class FakeHealthRepository implements HealthRepository {
  FakeHealthRepository(this._next);

  Future<ServerHealth> Function() _next;
  int calls = 0;

  set next(Future<ServerHealth> Function() value) => _next = value;

  @override
  Future<ServerHealth> readiness() {
    calls++;
    return _next();
  }
}

final class FakeAgentRepository implements AgentRepository {
  FakeAgentRepository(this._next);

  Future<AgentStatus> Function() _next;
  int statusCalls = 0;
  int openSettingsCalls = 0;

  set next(Future<AgentStatus> Function() value) => _next = value;

  @override
  Future<AgentStatus> status() {
    statusCalls++;
    return _next();
  }

  @override
  Future<void> openAccessibilitySettings() async {
    openSettingsCalls++;
  }
}

const ServerHealth readyHealth = ServerHealth(
  dependencies: <String, String>{
    'database': 'up',
    'pgvector': 'up',
    'redis': 'up',
  },
);

const AgentStatus disabledAgent = AgentStatus(accessibilityEnabled: false);

const AgentStatus enabledAgent = AgentStatus(accessibilityEnabled: true);

/// A future that never completes, for asserting loading states.
Future<T> never<T>() => Completer<T>().future;
