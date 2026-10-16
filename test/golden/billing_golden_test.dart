@Tags(<String>['golden'])
library;

import 'package:alesle_ai/features/billing/data/billing_data_providers.dart';
import 'package:alesle_ai/features/billing/presentation/limit_screen.dart';
import 'package:alesle_ai/features/billing/presentation/pay_screen.dart';
import 'package:alesle_ai/features/billing/presentation/plan_screen.dart';
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

  Future<void> shoot(WidgetTester tester, Widget screen, String name) async {
    phone(tester);
    final FakeBillingRepository billing = FakeBillingRepository()
      ..current = testBillingStatus(usedPercent: 64);
    await pumpLocalized(
      tester,
      screen,
      overrides: [billingRepositoryProvider.overrideWithValue(billing)],
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(screen.runtimeType),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  testWidgets('plan', (WidgetTester tester) async {
    await shoot(tester, const PlanScreen(), 'plan');
  });

  testWidgets('pay with', (WidgetTester tester) async {
    await shoot(tester, const PayScreen(product: 'pro'), 'pay');
  });

  testWidgets('limit used up', (WidgetTester tester) async {
    await shoot(tester, const LimitScreen(kind: LimitKind.month), 'limit');
  });
}
