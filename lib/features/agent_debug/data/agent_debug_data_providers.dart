import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/agent_console.dart';
import 'agent_console_repository_impl.dart';

final Provider<AgentConsoleRepository> agentConsoleRepositoryProvider =
    Provider<AgentConsoleRepository>((Ref ref) => AgentConsoleRepositoryImpl());
