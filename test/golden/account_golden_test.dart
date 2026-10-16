@Tags(<String>['golden'])
library;

import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/features/auth/data/auth_data_providers.dart';
import 'package:alesle_ai/features/auth/presentation/sign_in_screen.dart';
import 'package:alesle_ai/features/memory/data/memory_data_providers.dart';
import 'package:alesle_ai/features/memory/presentation/memory_screen.dart';
import 'package:alesle_ai/features/settings/data/settings_data_providers.dart';
import 'package:alesle_ai/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

/// Update after an intentional UI change:
///   flutter test --tags golden --update-goldens
void main() {
  void phone(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
  }

  testWidgets('sign in', (WidgetTester tester) async {
    phone(tester);
    await pumpLocalized(
      tester,
      const SignInScreen(),
      overrides: [
        authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
      ],
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SignInScreen),
      matchesGoldenFile('goldens/sign_in.png'),
    );
  });

  testWidgets('settings', (WidgetTester tester) async {
    phone(tester);
    await pumpLocalized(
      tester,
      const SettingsScreen(),
      overrides: [
        accountRepositoryProvider.overrideWithValue(FakeAccountRepository()),
        appSettingsStoreProvider.overrideWithValue(await testSettingsStore()),
      ],
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(SettingsScreen),
      matchesGoldenFile('goldens/settings.png'),
    );
  });

  testWidgets('memory', (WidgetTester tester) async {
    phone(tester);
    await pumpLocalized(
      tester,
      const MemoryScreen(),
      overrides: [
        memoryRepositoryProvider.overrideWithValue(FakeMemoryRepository()),
      ],
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MemoryScreen),
      matchesGoldenFile('goldens/memory.png'),
    );
  });
}
