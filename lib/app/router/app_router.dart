import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/agent_debug/presentation/agent_debug_screen.dart';
import '../../features/home/presentation/home_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';

  /// Developer console; registered in debug builds only.
  static const String agentDebug = '/debug/agent';
}

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.agentDebug,
          builder: (_, _) => const AgentDebugScreen(),
        ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
