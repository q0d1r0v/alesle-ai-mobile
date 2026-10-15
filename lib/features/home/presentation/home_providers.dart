import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/home_data_providers.dart';
import '../domain/agent_status.dart';
import '../domain/server_health.dart';

export '../data/home_data_providers.dart'
    show agentRepositoryProvider, healthRepositoryProvider;

final FutureProvider<ServerHealth> serverHealthProvider =
    FutureProvider.autoDispose<ServerHealth>(
      (Ref ref) => ref.watch(healthRepositoryProvider).readiness(),
    );

final FutureProvider<AgentStatus> agentStatusProvider =
    FutureProvider.autoDispose<AgentStatus>(
      (Ref ref) => ref.watch(agentRepositoryProvider).status(),
    );
