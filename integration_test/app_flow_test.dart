import 'package:alesle_ai/app/app.dart';
import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/core/network/dio_factory.dart';
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

  testWidgets('home shows server readiness and the native agent status', (
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
        ],
        child: const AlesleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('server-status-card')), findsOneWidget);
    expect(
      find.byKey(const Key('enable-accessibility-button')),
      findsOneWidget,
    );
  });
}
