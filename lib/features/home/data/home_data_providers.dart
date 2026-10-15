import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/core_providers.dart';
import '../../../core/api/generated/clients/health_api.dart';
import '../domain/home_repositories.dart';
import 'agent_repository_impl.dart';
import 'health_repository_impl.dart';

/// Wiring of the data layer. Presentation depends on the domain interfaces
/// these expose, never on the generated clients behind them.
final Provider<HealthRepository> healthRepositoryProvider =
    Provider<HealthRepository>(
      (Ref ref) => HealthRepositoryImpl(HealthApi(ref.watch(dioProvider))),
    );

final Provider<AgentRepository> agentRepositoryProvider =
    Provider<AgentRepository>((Ref ref) => AgentRepositoryImpl());
