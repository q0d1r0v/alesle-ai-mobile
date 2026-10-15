import 'package:alesle_ai/app/app.dart';
import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:alesle_ai/features/home/presentation/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  const AppConfig config = AppConfig(
    environment: AppEnvironment.dev,
    distribution: Distribution.play,
    apiBaseUrl: 'http://api.test',
  );

  group('resolveLocale', () {
    const List<Locale> supported = <Locale>[
      Locale('en'),
      Locale('ru'),
      Locale('uz'),
    ];

    test('matches by language code', () {
      expect(
        resolveLocale(const Locale('ru', 'RU'), supported),
        const Locale('ru'),
      );
    });

    test('falls back to Uzbek for unsupported or missing locales', () {
      expect(resolveLocale(const Locale('de'), supported), const Locale('uz'));
      expect(resolveLocale(null, supported), const Locale('uz'));
    });
  });

  testWidgets('boots into the home screen through the router', (
    WidgetTester tester,
  ) async {
    tester.platformDispatcher.localesTestValue = const <Locale>[Locale('ru')];
    addTearDown(tester.platformDispatcher.clearLocalesTestValue);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          healthRepositoryProvider.overrideWithValue(
            FakeHealthRepository(() async => readyHealth),
          ),
          agentRepositoryProvider.overrideWithValue(
            FakeAgentRepository(() async => disabledPlayAgent),
          ),
        ],
        child: const AlesleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Работает'), findsOneWidget);
  });

  test('appConfigProvider must be overridden', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    expect(() => container.read(appConfigProvider), throwsA(anything));
  });

  test(
    'dioProvider and the default repositories are built from the config',
    () {
      final ProviderContainer container = ProviderContainer(
        overrides: [appConfigProvider.overrideWithValue(config)],
      );
      addTearDown(container.dispose);

      expect(container.read(dioProvider), isA<Dio>());
      expect(container.read(dioProvider).options.baseUrl, 'http://api.test');
      expect(container.read(healthRepositoryProvider), isNotNull);
      expect(container.read(agentRepositoryProvider), isNotNull);
    },
  );
}
