import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/auth/api_token_refresher.dart';
import '../../core/auth/auth_session.dart';
import '../../core/auth/link_nonce_store.dart';
import '../../core/auth/session_controller.dart';
import '../../core/auth/session_store.dart';
import '../../core/config/app_build.dart';
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

/// This installed build; `bootstrap()` reads it from Android.
final Provider<AppBuild> appBuildProvider = Provider<AppBuild>(
  (Ref ref) => AppBuild.unknown,
);

/// True once the server said this version is too old (426, EC-15) or the
/// manifest requires an update: the router then shows only the update screen.
class UpgradeRequiredController extends Notifier<bool> {
  @override
  bool build() => false;

  void require() => state = true;
}

final NotifierProvider<UpgradeRequiredController, bool>
upgradeRequiredProvider = NotifierProvider<UpgradeRequiredController, bool>(
  UpgradeRequiredController.new,
);

/// Requests as the signed-in user: bearer token, refreshed as needed.
final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  final Dio dio = createDio(
    ref.watch(appConfigProvider),
    tokens: ref.read(sessionProvider.notifier),
    build: ref.watch(appBuildProvider),
    onUpgradeRequired: () =>
        ref.read(upgradeRequiredProvider.notifier).require(),
  );
  ref.onDispose(dio.close);
  return dio;
});

/// Requests without a user: sign-in, refresh, health.
final Provider<Dio> anonymousDioProvider = Provider<Dio>((Ref ref) {
  final Dio dio = createDio(
    ref.watch(appConfigProvider),
    build: ref.watch(appBuildProvider),
    onUpgradeRequired: () =>
        ref.read(upgradeRequiredProvider.notifier).require(),
  );
  ref.onDispose(dio.close);
  return dio;
});

/// Opens a web page outside the app (legal pages, support); tests replace it.
typedef LinkOpener = Future<bool> Function(Uri url);

final Provider<LinkOpener> linkOpenerProvider = Provider<LinkOpener>(
  (Ref ref) =>
      (Uri url) => launchUrl(url, mode: LaunchMode.externalApplication),
);

/// Overridden in `bootstrap()` with the secure store.
final Provider<SessionStore> sessionStoreProvider = Provider<SessionStore>(
  (Ref ref) => throw StateError(
    'sessionStoreProvider must be overridden (see bootstrap()).',
  ),
);

/// Magic-link nonces (secure storage); tests replace it.
final Provider<LinkNonceStore> linkNonceStoreProvider =
    Provider<LinkNonceStore>((Ref ref) => SecureLinkNonceStore());

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
