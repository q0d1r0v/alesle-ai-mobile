import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final Provider<Dio> dioProvider = Provider<Dio>((Ref ref) {
  final Dio dio = createDio(ref.watch(appConfigProvider));
  ref.onDispose(dio.close);
  return dio;
});

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
