import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/agent_debug/presentation/agent_debug_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../bootstrap/core_providers.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';

  /// Developer console; registered in debug builds only.
  static const String agentDebug = '/debug/agent';
}

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    // A new install starts with onboarding; it never comes back once done.
    redirect: (BuildContext context, GoRouterState state) {
      final bool done = ref.read(appSettingsProvider).onboardingDone;
      final bool onOnboarding = state.matchedLocation == AppRoutes.onboarding;
      if (!done && !onOnboarding) return AppRoutes.onboarding;
      if (done && onOnboarding) return AppRoutes.home;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
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
