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
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:integration_test/integration_test.dart';

/// The whole app on a device: real router, real Pigeon bridge, real Dio stack.
/// HTTP is answered by a mock adapter so the test does not depend on a
/// running backend; the API contract itself is covered by the backend's e2e
/// suite and the committed OpenAPI file.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<AppSettingsStore> settings({required bool onboardingDone}) async {
    final AppSettingsStore store = await AppSettingsStore.load();
    await store.write(AppSettings(onboardingDone: onboardingDone));
    return store;
  }

  testWidgets('a first launch starts with onboarding', (
    WidgetTester tester,
  ) async {
    final AppConfig config = AppConfig.parse(
      environment: 'dev',
      apiBaseUrl: 'http://api.test',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          appSettingsStoreProvider.overrideWithValue(
            await settings(onboardingDone: false),
          ),
          sessionStoreProvider.overrideWithValue(MemorySessionStore()),
        ],
        child: const AlesleApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('onboarding-start')), findsOneWidget);
  });

  testWidgets('onboarded but signed out: the sign-in screen', (
    WidgetTester tester,
  ) async {
    final AppConfig config = AppConfig.parse(
      environment: 'dev',
      apiBaseUrl: 'http://api.test',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          appSettingsStoreProvider.overrideWithValue(
            await settings(onboardingDone: true),
          ),
          sessionStoreProvider.overrideWithValue(MemorySessionStore()),
        ],
        child: const AlesleApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('sign-in-email')), findsOneWidget);
  });

  testWidgets('home shows the native agent status: off until enabled', (
    WidgetTester tester,
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

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          dioProvider.overrideWithValue(dio),
          appSettingsStoreProvider.overrideWithValue(
            await settings(onboardingDone: true),
          ),
          ...signedIn(),
        ],
        child: const AlesleApp(),
      ),
    );
    await tester.pumpAndSettle();

    // A freshly installed app has no accessibility: "Alesle is off".
    expect(find.byKey(const Key('off-view')), findsOneWidget);
    expect(
      find.byKey(const Key('enable-accessibility-button')),
      findsOneWidget,
    );
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
