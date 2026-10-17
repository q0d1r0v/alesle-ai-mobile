import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/config/app_build.dart';
import 'package:alesle_ai/features/auth/data/auth_data_providers.dart';
import 'package:alesle_ai/features/auth/presentation/sign_in_screen.dart';
import 'package:alesle_ai/features/billing/data/billing_data_providers.dart';
import 'package:alesle_ai/features/billing/domain/billing.dart';
import 'package:alesle_ai/features/billing/presentation/limit_screen.dart';
import 'package:alesle_ai/features/billing/presentation/pay_screen.dart';
import 'package:alesle_ai/features/billing/presentation/plan_screen.dart';
import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:alesle_ai/features/home/presentation/home_screen.dart';
import 'package:alesle_ai/features/memory/data/memory_data_providers.dart';
import 'package:alesle_ai/features/memory/presentation/history_screen.dart';
import 'package:alesle_ai/features/memory/presentation/memory_screen.dart';
import 'package:alesle_ai/features/onboarding/data/onboarding_data_providers.dart';
import 'package:alesle_ai/features/onboarding/presentation/onboarding_screen.dart';
import 'package:alesle_ai/features/settings/data/settings_data_providers.dart';
import 'package:alesle_ai/features/settings/presentation/settings_screen.dart';
import 'package:alesle_ai/features/update/data/update_data_providers.dart';
import 'package:alesle_ai/features/update/presentation/update_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

/// AC-APP-5: every main screen in Uzbek, Russian and English fits a small
/// phone with large text — a translation that is too long fails here (any
/// overflow is a test exception), not on a user's phone.
void main() {
  const List<Locale> locales = <Locale>[
    Locale('uz'),
    Locale('ru'),
    Locale('en'),
  ];

  Future<List<Override>> overrides() async => <Override>[
    assistantRepositoryProvider.overrideWithValue(FakeAssistantRepository()),
    handsFreeRepositoryProvider.overrideWithValue(FakeHandsFreeRepository()),
    voiceRepositoryProvider.overrideWithValue(
      FakeVoiceRepository()..microphone = false,
    ),
    healthRepositoryProvider.overrideWithValue(
      FakeHealthRepository(() async => readyHealth),
    ),
    agentRepositoryProvider.overrideWithValue(
      FakeAgentRepository(() async => enabledAgent),
    ),
    authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
    accountRepositoryProvider.overrideWithValue(FakeAccountRepository()),
    memoryRepositoryProvider.overrideWithValue(FakeMemoryRepository()),
    deviceSetupRepositoryProvider.overrideWithValue(FakeDeviceSetup()),
    billingRepositoryProvider.overrideWithValue(
      FakeBillingRepository()
        ..current = testBillingStatus(
          plan: 'pro',
          usedPercent: 85,
          subscription: SubscriptionState.active,
        ),
    ),
    updateRepositoryProvider.overrideWithValue(
      FakeUpdateRepository()..newest = testRelease(minSupported: 4),
    ),
    appBuildProvider.overrideWithValue(
      const AppBuild(versionCode: 3, versionName: '0.3.0', certSha256: ''),
    ),
    appSettingsStoreProvider.overrideWithValue(
      await testSettingsStore(onboardingDone: false),
    ),
  ];

  final Map<String, Widget Function()> screens = <String, Widget Function()>{
    'home': () => HomeScreen(now: () => DateTime(2026, 10, 16, 9)),
    'onboarding': () => const OnboardingScreen(),
    'sign in': () => const SignInScreen(),
    'settings': () => const SettingsScreen(),
    'memory': () => const MemoryScreen(),
    'history': () => const HistoryScreen(),
    'plan': () => const PlanScreen(),
    'pay': () => const PayScreen(product: 'max'),
    'limit (month)': () => const LimitScreen(kind: LimitKind.month),
    'limit (day)': () => const LimitScreen(kind: LimitKind.day),
    'update (required)': () => const UpdateScreen(mandatory: true),
    'update': () => const UpdateScreen(),
  };

  for (final Locale locale in locales) {
    for (final MapEntry<String, Widget Function()> screen in screens.entries) {
      testWidgets('${screen.key} fits in ${locale.languageCode}', (
        WidgetTester tester,
      ) async {
        // A 360 × 640 dp phone with the system font at 130 %.
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 3;
        tester.platformDispatcher.textScaleFactorTestValue = 1.3;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpLocalized(
          tester,
          screen.value(),
          overrides: await overrides(),
          locale: locale,
        );
        for (int i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
