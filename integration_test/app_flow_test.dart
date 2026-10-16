import 'package:alesle_ai/app/app.dart';
import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/core/network/dio_factory.dart';
import 'package:alesle_ai/core/storage/app_settings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        ],
        child: const AlesleApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('onboarding-start')), findsOneWidget);
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
