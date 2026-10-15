import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/app/l10n/app_localizations.dart';
import 'package:alesle_ai/app/router/app_router.dart';
import 'package:alesle_ai/app/theme/app_theme.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/storage/app_settings.dart';
import 'package:alesle_ai/features/onboarding/data/onboarding_data_providers.dart';
import 'package:alesle_ai/features/onboarding/domain/device_setup.dart';
import 'package:alesle_ai/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fakes.dart';

void main() {
  late FakeDeviceSetup device;
  late AppSettingsStore store;
  late ProviderContainer container;

  setUp(() async {
    device = FakeDeviceSetup();
    store = await testSettingsStore(onboardingDone: false);
  });

  /// Onboarding inside a small router, so finishing can navigate home.
  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.onboarding,
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, _) => const OnboardingScreen(),
        ),
        GoRoute(path: AppRoutes.home, builder: (_, _) => const Text('HOME')),
      ],
    );
    addTearDown(router.dispose);
    container = ProviderContainer(
      overrides: [
        deviceSetupRepositoryProvider.overrideWithValue(device),
        appSettingsStoreProvider.overrideWithValue(store),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, _) {
            final String? language = ref.watch(appSettingsProvider).language;
            return MaterialApp.router(
              theme: buildTheme(),
              locale: Locale(language ?? 'uz'),
              localizationsDelegates: const <LocalizationsDelegate<Object?>>[
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  Future<void> resume(WidgetTester tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
  }

  testWidgets('walks every step to home and remembers it', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    expect(find.text('Telefoningizga nima qilishni ayting'), findsOneWidget);
    await tapKey(tester, 'onboarding-start');

    expect(find.text('Tilingiz'), findsOneWidget);
    await tapKey(tester, 'language-en');
    expect(find.text('Your language'), findsOneWidget);
    expect(container.read(appSettingsProvider).language, 'en');
    await tapKey(tester, 'language-uz');
    await tapKey(tester, 'onboarding-continue');

    expect(find.text('Alesle qanday ishlaydi'), findsOneWidget);
    await tapKey(tester, 'onboarding-continue');

    expect(find.text('Uchta tez ruxsat'), findsOneWidget);
    await tapKey(tester, 'permissions-allow');
    expect(device.calls, <String>[
      'request:microphone',
      'request:contacts',
      'request:notifications',
    ]);
    await tapKey(tester, 'onboarding-continue');

    expect(find.text('Alesle’ni yoqing'), findsOneWidget);
    await tapKey(tester, 'turn-on-open-settings');
    expect(device.calls.last, 'accessibility');
    // Turned on in Settings, back in the app: the step completes by itself.
    device.accessibility = true;
    await resume(tester);

    expect(find.text('Alesle to‘xtab qolmasin'), findsOneWidget);
    await tapKey(tester, 'battery-exempt');
    await tapKey(tester, 'battery-autostart');
    expect(device.calls.sublist(device.calls.length - 2), <String>[
      'battery',
      'autostart',
    ]);
    await tapKey(tester, 'onboarding-continue');

    expect(find.text('Hammasi tayyor'), findsOneWidget);
    await tapKey(tester, 'onboarding-finish');
    expect(find.text('HOME'), findsOneWidget);
    expect(store.read().onboardingDone, isTrue);
  });

  testWidgets('a permanently denied permission sends the user to app info', (
    WidgetTester tester,
  ) async {
    device.statuses[SetupPermission.microphone] =
        PermissionStatus.permanentlyDenied;
    await pump(tester);
    await tapKey(tester, 'onboarding-start');
    await tapKey(tester, 'onboarding-continue');
    await tapKey(tester, 'onboarding-continue');
    expect(find.text('Sozlamalarda yoqish'), findsOneWidget);
    await tapKey(tester, 'permissions-allow');
    expect(device.calls, <String>['appDetails']);
  });

  testWidgets('a denial keeps the step open and "later" moves on', (
    WidgetTester tester,
  ) async {
    device.answer = PermissionStatus.denied;
    await pump(tester);
    await tapKey(tester, 'onboarding-start');
    await tapKey(tester, 'onboarding-continue');
    await tapKey(tester, 'onboarding-continue');
    await tapKey(tester, 'permissions-allow');
    expect(find.byKey(const Key('permissions-allow')), findsOneWidget);
    await tapKey(tester, 'onboarding-later');
    expect(find.text('Alesle’ni yoqing'), findsOneWidget);
  });

  testWidgets('explains restricted settings when the switch is grey', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    await tapKey(tester, 'onboarding-start');
    await tapKey(tester, 'onboarding-continue');
    await tapKey(tester, 'onboarding-continue');
    await tapKey(tester, 'onboarding-later');
    await tapKey(tester, 'turn-on-grey-help');
    expect(find.text('Cheklangan sozlamalarga ruxsat bering'), findsOneWidget);
    expect(find.text('Yuqoridagi ⋮ menyusini bosing'), findsOneWidget);
    await tapKey(tester, 'restricted-open-app-info');
    expect(device.calls.last, 'appDetails');
    await tapKey(tester, 'onboarding-later');
    expect(find.text('Alesle to‘xtab qolmasin'), findsOneWidget);
  });

  testWidgets(
    'no restricted-settings help before Android 13, no autostart on a Pixel',
    (WidgetTester tester) async {
      device.device = const DeviceSetup(
        batteryOptimizationIgnored: true,
        manufacturer: 'google',
        sdkInt: 31,
      );
      await pump(tester);
      await tapKey(tester, 'onboarding-start');
      await tapKey(tester, 'onboarding-continue');
      await tapKey(tester, 'onboarding-continue');
      await tapKey(tester, 'onboarding-later');
      expect(find.byKey(const Key('turn-on-grey-help')), findsNothing);
      await tapKey(tester, 'onboarding-later');
      expect(find.byKey(const Key('battery-autostart')), findsNothing);
      // Already exempt: shown as done, nothing to tap.
      await tapKey(tester, 'battery-exempt');
      expect(device.calls, isEmpty);
    },
  );

  testWidgets('an already enabled switch lets the user continue', (
    WidgetTester tester,
  ) async {
    device.accessibility = true;
    for (final SetupPermission permission in SetupPermission.values) {
      device.statuses[permission] = PermissionStatus.granted;
    }
    await pump(tester);
    await tapKey(tester, 'onboarding-start');
    await tapKey(tester, 'onboarding-continue');
    await tapKey(tester, 'onboarding-continue');
    // Everything granted: no "Allow", straight on.
    expect(find.byKey(const Key('permissions-allow')), findsNothing);
    await tapKey(tester, 'onboarding-continue');
    await tapKey(tester, 'onboarding-continue');
    expect(find.text('Alesle to‘xtab qolmasin'), findsOneWidget);
  });

  testWidgets('back goes one step back', (WidgetTester tester) async {
    await pump(tester);
    await tapKey(tester, 'onboarding-start');
    await tapKey(tester, 'onboarding-continue');
    await tapKey(tester, 'onboarding-back');
    expect(find.text('Tilingiz'), findsOneWidget);
    final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
    expect(widgetsAppState, isNotNull);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Telefoningizga nima qilishni ayting'), findsOneWidget);
  });

  testWidgets('a broken bridge leaves the steps usable', (
    WidgetTester tester,
  ) async {
    device.failure = const UnexpectedFailure('bridge');
    await pump(tester);
    await tapKey(tester, 'onboarding-start');
    expect(find.text('Tilingiz'), findsOneWidget);
    await resume(tester);
    expect(tester.takeException(), isNull);
  });
}
