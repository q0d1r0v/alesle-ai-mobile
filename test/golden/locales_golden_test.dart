@Tags(<String>['golden'])
library;

import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/features/billing/data/billing_data_providers.dart';
import 'package:alesle_ai/features/billing/presentation/limit_screen.dart';
import 'package:alesle_ai/features/billing/presentation/plan_screen.dart';
import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:alesle_ai/features/home/presentation/home_screen.dart';
import 'package:alesle_ai/features/settings/data/settings_data_providers.dart';
import 'package:alesle_ai/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

/// The main screens in Russian and English (Uzbek is in the other golden
/// files). Update after an intentional UI change:
///   flutter test --tags golden --update-goldens
void main() {
  final Map<String, Widget Function()> screens = <String, Widget Function()>{
    'home': () => HomeScreen(now: () => DateTime(2026, 10, 16, 20)),
    'settings': () => const SettingsScreen(),
    'plan': () => const PlanScreen(),
    'limit': () => const LimitScreen(kind: LimitKind.month),
  };

  for (final String lang in <String>['ru', 'en']) {
    for (final MapEntry<String, Widget Function()> screen in screens.entries) {
      testWidgets('${screen.key} — $lang', (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);
        final Widget widget = screen.value();
        await pumpLocalized(
          tester,
          widget,
          locale: Locale(lang),
          overrides: [
            assistantRepositoryProvider.overrideWithValue(
              FakeAssistantRepository(),
            ),
            healthRepositoryProvider.overrideWithValue(
              FakeHealthRepository(() async => readyHealth),
            ),
            agentRepositoryProvider.overrideWithValue(
              FakeAgentRepository(() async => enabledAgent),
            ),
            accountRepositoryProvider.overrideWithValue(
              FakeAccountRepository(),
            ),
            appSettingsStoreProvider.overrideWithValue(
              await testSettingsStore(),
            ),
            billingRepositoryProvider.overrideWithValue(
              FakeBillingRepository()
                ..current = testBillingStatus(usedPercent: 64),
            ),
            handsFreeRepositoryProvider.overrideWithValue(
              FakeHandsFreeRepository(),
            ),
            voiceRepositoryProvider.overrideWithValue(
              FakeVoiceRepository()..microphone = false,
            ),
          ],
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(widget.runtimeType),
          matchesGoldenFile('goldens/${screen.key}_$lang.png'),
        );
      });
    }
  }
}
