import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';

abstract final class AppRoutes {
  static const String home = '/';
}

final Provider<GoRouter> routerProvider = Provider<GoRouter>((Ref ref) {
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      GoRoute(path: AppRoutes.home, builder: (_, _) => const HomeScreen()),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
