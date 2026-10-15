@Tags(<String>['golden'])
library;

import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/features/onboarding/data/onboarding_data_providers.dart';
import 'package:alesle_ai/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

/// Update after an intentional UI change:
///   flutter test --tags golden --update-goldens
void main() {
  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      const OnboardingScreen(),
      overrides: [
        deviceSetupRepositoryProvider.overrideWithValue(FakeDeviceSetup()),
        appSettingsStoreProvider.overrideWithValue(
          await testSettingsStore(onboardingDone: false),
        ),
      ],
    );
    await tester.pumpAndSettle();
  }

  Future<void> next(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('onboarding — welcome', (WidgetTester tester) async {
    await pump(tester);
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/onboarding_welcome.png'),
    );
  });

  testWidgets('onboarding — turn on', (WidgetTester tester) async {
    await pump(tester);
    await next(tester, 'onboarding-start');
    await next(tester, 'onboarding-continue');
    await next(tester, 'onboarding-continue');
    await next(tester, 'onboarding-later');
    await expectLater(
      find.byType(OnboardingScreen),
      matchesGoldenFile('goldens/onboarding_turn_on.png'),
    );
  });
}
