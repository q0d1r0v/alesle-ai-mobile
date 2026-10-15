@Tags(<String>['golden'])
library;

import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:alesle_ai/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

/// Update after an intentional UI change:
///   flutter test --tags golden --update-goldens
void main() {
  Future<void> pumpAt(WidgetTester tester, FakeAgentRepository agent) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      const HomeScreen(),
      overrides: [
        healthRepositoryProvider.overrideWithValue(
          FakeHealthRepository(() async => readyHealth),
        ),
        agentRepositoryProvider.overrideWithValue(agent),
      ],
    );
    await tester.pumpAndSettle();
  }

  testWidgets('home — accessibility off', (WidgetTester tester) async {
    await pumpAt(tester, FakeAgentRepository(() async => disabledAgent));
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_setup_needed.png'),
    );
  });

  testWidgets('home — ready', (WidgetTester tester) async {
    await pumpAt(tester, FakeAgentRepository(() async => enabledAgent));
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_ready.png'),
    );
  });
}
