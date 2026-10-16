import 'package:alesle_ai/app/app.dart';
import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/auth/auth_session.dart';
import 'package:alesle_ai/core/auth/session_store.dart';
import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/core/network/dio_factory.dart';
import 'package:alesle_ai/core/storage/app_settings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:patrol/patrol.dart';

/// End-to-end on an emulator, across the app/OS boundary that plain
/// integration_test cannot cross: tapping "Yoqish" must leave the app for the
/// system Accessibility settings, and coming back must re-check the status.
///
///   patrol test --dart-define-from-file=env/dev.json
void main() {
  patrolTest('enable button opens system Accessibility settings and returns', (
    $,
  ) async {
    final AppConfig config = AppConfig.parse(
      environment: 'dev',
      apiBaseUrl: 'http://api.test',
    );
    final Dio dio = createDio(config);
    DioAdapter(dio: dio).onGet(
      '/v1/health/ready',
      (server) => server.reply(200, <String, Object?>{
        'status': 'ok',
        'dependencies': <String, String>{
          'database': 'up',
          'pgvector': 'up',
          'redis': 'up',
        },
      }),
    );

    final AppSettingsStore store = await AppSettingsStore.load();
    await store.write(const AppSettings(onboardingDone: true));

    await $.pumpWidgetAndSettle(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          dioProvider.overrideWithValue(dio),
          appSettingsStoreProvider.overrideWithValue(store),
          ...signedIn(),
        ],
        child: const AlesleApp(),
      ),
    );

    await $(const Key('enable-accessibility-button')).tap();

    // Now in the system Settings app; our app is in the background.
    await $.platform.mobile.waitUntilVisible(
      Selector(textContains: 'Alesle AI'),
    );

    await $.platform.android.pressBack();
    await $.pumpAndSettle();

    // Back in the app; status was re-read on resume and is still "needs setup".
    await $(const Key('enable-accessibility-button')).waitUntilVisible();
  });
}

/// A signed-in session kept in memory: the HTTP calls here are mocked, so
/// the token is never checked.
List<Override> signedIn() {
  final AuthSession session = AuthSession(
    accessToken: 'device-test-token',
    refreshToken: 'device-test-refresh',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
    userId: '0190f0a0-0000-7000-8000-000000000001',
    email: 'device@alesle.test',
  );
  return <Override>[
    sessionStoreProvider.overrideWithValue(MemorySessionStore(session)),
    initialSessionProvider.overrideWithValue(session),
  ];
}
