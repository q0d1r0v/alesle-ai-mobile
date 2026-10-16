import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/agent_debug/presentation/agent_debug_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../bootstrap/core_providers.dart';

abstract final class AppRoutes {
  static const String home = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String settings = '/settings';

  /// Developer console; registered in debug builds only.
  static const String agentDebug = '/debug/agent';
}

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    // Onboarding first, then signing in (step 9); neither comes back once
    // done, except signing in after a sign-out.
    redirect: (BuildContext context, GoRouterState state) => gateFor(
      onboardingDone: ref.read(appSettingsProvider).onboardingDone,
      signedIn: ref.read(sessionProvider) != null,
      location: state.matchedLocation,
    ),
    routes: <RouteBase>[
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(path: AppRoutes.signIn, builder: (_, _) => const SignInScreen()),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, _) => const SettingsScreen(),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.agentDebug,
          builder: (_, _) => const AgentDebugScreen(),
        ),
    ],
  );
  // Signing in or out moves the user at once, wherever they are.
  ref
    ..listen(sessionProvider, (_, _) => router.refresh())
    ..onDispose(router.dispose);
  return router;
});

/// Where a location must go instead, or null to stay.
String? gateFor({
  required bool onboardingDone,
  required bool signedIn,
  required String location,
}) {
  if (!onboardingDone) {
    return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
  }
  if (!signedIn) return location == AppRoutes.signIn ? null : AppRoutes.signIn;
  if (location == AppRoutes.onboarding || location == AppRoutes.signIn) {
    return AppRoutes.home;
  }
  return null;
}
