import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/home_data_providers.dart';
import '../domain/agent_status.dart';
import '../domain/server_health.dart';

export '../data/home_data_providers.dart'
    show
        agentRepositoryProvider,
        assistantRepositoryProvider,
        healthRepositoryProvider;

final FutureProvider<ServerHealth> serverHealthProvider =
    FutureProvider.autoDispose<ServerHealth>(
      (Ref ref) => ref.watch(healthRepositoryProvider).readiness(),
    );

final FutureProvider<AgentStatus> agentStatusProvider =
    FutureProvider.autoDispose<AgentStatus>(
      (Ref ref) => ref.watch(agentRepositoryProvider).status(),
    );

/// The user's "confirm every sensitive action" setting. On by default; read
/// from the server profile once accounts exist (SOW sprint 5, AC-APP-4).
final Provider<ExecutionPolicy> executionPolicyProvider =
    Provider<ExecutionPolicy>(
      (Ref ref) => ExecutionPolicy.confirmSensitiveActions,
    );
