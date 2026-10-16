import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/api_token_refresher.dart';
import '../../core/auth/auth_session.dart';
import '../../core/auth/session_controller.dart';
import '../../core/auth/session_store.dart';
import '../../core/config/app_config.dart';
import '../../core/network/dio_factory.dart';
import '../../core/platform/agent_events_bridge.dart';
import '../../core/storage/app_settings.dart';

/// Overridden in `bootstrap()` with the validated build configuration.
final Provider<AppConfig> appConfigProvider = Provider<AppConfig>(
  (Ref ref) => throw StateError(
    'appConfigProvider must be overridden in ProviderScope (see bootstrap()).',
  ),
);

/// Requests as the signed-in user: bearer token, refreshed as needed.
final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  final Dio dio = createDio(
    ref.watch(appConfigProvider),
    tokens: ref.read(sessionProvider.notifier),
  );
  ref.onDispose(dio.close);
  return dio;
});

/// Requests without a user: sign-in, refresh, health.
final Provider<Dio> anonymousDioProvider = Provider<Dio>((Ref ref) {
  final Dio dio = createDio(ref.watch(appConfigProvider));
  ref.onDispose(dio.close);
  return dio;
});

/// Overridden in `bootstrap()` with the secure store.
final Provider<SessionStore> sessionStoreProvider = Provider<SessionStore>(
  (Ref ref) => throw StateError(
    'sessionStoreProvider must be overridden (see bootstrap()).',
  ),
);

/// The session read from the store at startup (bootstrap overrides it).
final Provider<AuthSession?> initialSessionProvider = Provider<AuthSession?>(
  (Ref ref) => null,
);

final Provider<TokenRefresher> tokenRefresherProvider =
    Provider<TokenRefresher>(
      (Ref ref) => apiTokenRefresher(ref.read(anonymousDioProvider)),
    );

/// The signed-in user's session; null when signed out.
final NotifierProvider<SessionController, AuthSession?> sessionProvider =
    NotifierProvider<SessionController, AuthSession?>(
      () => SessionController(
        store: (Ref ref) => ref.read(sessionStoreProvider),
        initial: (Ref ref) => ref.read(initialSessionProvider),
        refresher: (Ref ref) => ref.read(tokenRefresherProvider),
      ),
    );

/// One bridge per app: native task events reach every listener through it.
final Provider<AgentEventsBridge> agentEventsBridgeProvider =
    Provider<AgentEventsBridge>((Ref ref) => AgentEventsBridge());

/// Overridden in `bootstrap()` with the loaded store.
final Provider<AppSettingsStore> appSettingsStoreProvider =
    Provider<AppSettingsStore>(
      (Ref ref) => throw StateError(
        'appSettingsStoreProvider must be overridden (see bootstrap()).',
      ),
    );

/// The user's settings; every change is written through.
class AppSettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.watch(appSettingsStoreProvider).read();

  Future<void> update(AppSettings Function(AppSettings) change) async {
    final AppSettings next = change(state);
    state = next;
    await ref.read(appSettingsStoreProvider).write(next);
  }
}

final NotifierProvider<AppSettingsController, AppSettings> appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );
