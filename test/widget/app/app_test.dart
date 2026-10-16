import 'dart:async';

import 'package:alesle_ai/app/account_links.dart';
import 'package:alesle_ai/app/app.dart';
import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/api/generated/models/error_code.dart';
import 'package:alesle_ai/core/auth/session_store.dart';
import 'package:alesle_ai/core/config/app_build.dart';
import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/storage/app_settings.dart';
import 'package:alesle_ai/features/agent_debug/data/agent_debug_data_providers.dart';
import 'package:alesle_ai/features/agent_debug/domain/agent_console.dart';
import 'package:alesle_ai/features/agent_debug/presentation/agent_debug_screen.dart';
import 'package:alesle_ai/features/auth/data/auth_data_providers.dart';
import 'package:alesle_ai/features/auth/presentation/sign_in_screen.dart';
import 'package:alesle_ai/features/billing/data/billing_data_providers.dart';
import 'package:alesle_ai/features/billing/presentation/limit_screen.dart';
import 'package:alesle_ai/features/billing/presentation/payment_status_screen.dart';
import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:alesle_ai/features/home/presentation/home_screen.dart';
import 'package:alesle_ai/features/onboarding/data/onboarding_data_providers.dart';
import 'package:alesle_ai/features/onboarding/presentation/onboarding_screen.dart';
import 'package:alesle_ai/features/settings/data/settings_data_providers.dart';
import 'package:alesle_ai/features/settings/domain/account.dart';
import 'package:alesle_ai/features/update/data/update_data_providers.dart';
import 'package:alesle_ai/features/update/presentation/update_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  const AppConfig config = AppConfig(
    environment: AppEnvironment.dev,
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
            FakeAgentRepository(() async => enabledAgent),
          ),
          appSettingsStoreProvider.overrideWithValue(await testSettingsStore()),
          ...signedInOverrides(),
          assistantRepositoryProvider.overrideWithValue(
            FakeAssistantRepository(),
          ),
          voiceRepositoryProvider.overrideWithValue(FakeVoiceRepository()),
        ],
        child: const AlesleApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Нажмите и говорите'), findsOneWidget);
  });

  testWidgets('a long press on the title opens the agent console (debug)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          healthRepositoryProvider.overrideWithValue(
            FakeHealthRepository(() async => readyHealth),
          ),
          agentRepositoryProvider.overrideWithValue(
            FakeAgentRepository(() async => disabledAgent),
          ),
          agentConsoleRepositoryProvider.overrideWithValue(_SilentConsole()),
          appSettingsStoreProvider.overrideWithValue(await testSettingsStore()),
          ...signedInOverrides(),
          assistantRepositoryProvider.overrideWithValue(
            FakeAssistantRepository(),
          ),
          voiceRepositoryProvider.overrideWithValue(FakeVoiceRepository()),
        ],
        child: const AlesleApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(const Key('home-title')));
    await tester.pumpAndSettle();
    expect(find.byType(AgentDebugScreen), findsOneWidget);
  });

  testWidgets('a new install starts with onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          appSettingsStoreProvider.overrideWithValue(
            await testSettingsStore(onboardingDone: false),
          ),
          deviceSetupRepositoryProvider.overrideWithValue(FakeDeviceSetup()),
        ],
        child: const AlesleApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('the chosen language wins over the phone', (
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
            FakeAgentRepository(() async => enabledAgent),
          ),
          appSettingsStoreProvider.overrideWithValue(
            await testSettingsStore(language: 'en'),
          ),
          ...signedInOverrides(),
          assistantRepositoryProvider.overrideWithValue(
            FakeAssistantRepository(),
          ),
          voiceRepositoryProvider.overrideWithValue(FakeVoiceRepository()),
        ],
        child: const AlesleApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tap and speak'), findsOneWidget);
  });

  group('signing in', () {
    late StreamController<Uri> links;
    late FakeAuthRepository auth;
    late FakeAccountRepository account;
    late MemorySessionStore store;

    setUp(() {
      links = StreamController<Uri>();
      auth = FakeAuthRepository();
      account = FakeAccountRepository();
      store = MemorySessionStore();
    });

    tearDown(() => links.close());

    Future<ProviderContainer> pumpSignedOut(
      WidgetTester tester, {
      String? language,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(config),
            healthRepositoryProvider.overrideWithValue(
              FakeHealthRepository(() async => readyHealth),
            ),
            agentRepositoryProvider.overrideWithValue(
              FakeAgentRepository(() async => enabledAgent),
            ),
            appSettingsStoreProvider.overrideWithValue(
              await testSettingsStore(language: language),
            ),
            assistantRepositoryProvider.overrideWithValue(
              FakeAssistantRepository(),
            ),
            voiceRepositoryProvider.overrideWithValue(FakeVoiceRepository()),
            sessionStoreProvider.overrideWithValue(store),
            initialSessionProvider.overrideWithValue(null),
            incomingLinksProvider.overrideWithValue(links.stream),
            authRepositoryProvider.overrideWithValue(auth),
            accountRepositoryProvider.overrideWithValue(account),
          ],
          child: const AlesleApp(),
        ),
      );
      await tester.pumpAndSettle();
      return ProviderScope.containerOf(tester.element(find.byType(AlesleApp)));
    }

    testWidgets('signed out, onboarding done: the sign-in screen', (
      WidgetTester tester,
    ) async {
      await pumpSignedOut(tester);
      expect(find.byType(SignInScreen), findsOneWidget);
    });

    testWidgets('a sign-in link signs in, syncs the account and goes home', (
      WidgetTester tester,
    ) async {
      account.current = const Profile(
        email: 'aziz@example.com',
        emailVerified: true,
        displayName: null,
        language: 'en',
        confirmSensitiveActions: false,
        deletionScheduledAt: null,
      );
      final ProviderContainer container = await pumpSignedOut(
        tester,
        language: 'en',
      );
      auth.onSignIn = () =>
          container.read(sessionProvider.notifier).signIn(testPair());
      links.add(Uri.parse('https://alesle.ai/auth/link?token=tok-1'));
      await tester.pumpAndSettle();

      expect(auth.calls, <String>['magic:tok-1']);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(store.session?.email, 'aziz@example.com');
      // The phone's language went to the account; the account's setting came back.
      expect(account.calls, contains('update::en:'));
      expect(
        container.read(appSettingsProvider).confirmSensitiveActions,
        isFalse,
      );
    });

    testWidgets('a confirmation link confirms; a bad one explains', (
      WidgetTester tester,
    ) async {
      await pumpSignedOut(tester);
      links.add(Uri.parse('https://alesle.ai/auth/verify?token=tok-2'));
      await tester.pumpAndSettle();
      expect(auth.calls, <String>['verify:tok-2']);
      expect(find.text('Email confirmed.'), findsOneWidget);

      auth.failure = const ServerFailure(
        code: ErrorCode.linkInvalid,
        statusCode: 400,
      );
      links
        ..add(Uri.parse('https://alesle.ai/auth/link?token=old'))
        ..add(Uri.parse('https://example.com/elsewhere'));
      await tester.pumpAndSettle();
      expect(
        find.text('This link expired or was already used. Ask for a new one.'),
        findsOneWidget,
      );
      expect(auth.calls, <String>['verify:tok-2', 'magic:old']);
    });

    testWidgets('signing out anywhere returns to the sign-in screen', (
      WidgetTester tester,
    ) async {
      final ProviderContainer container = await pumpSignedOut(tester);
      await container.read(sessionProvider.notifier).signIn(testPair());
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
      await container.read(sessionProvider.notifier).signOut();
      await tester.pumpAndSettle();
      expect(find.byType(SignInScreen), findsOneWidget);
    });
  });

  test('appSettingsStoreProvider must be overridden', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    expect(() => container.read(appSettingsStoreProvider), throwsA(anything));
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
      expect(container.read(voiceRepositoryProvider), isNotNull);
      expect(container.read(deviceSetupRepositoryProvider), isNotNull);
    },
  );

  group('billing', () {
    late StreamController<Uri> links;
    late FakeBillingRepository billing;
    late FakeAssistantRepository assistant;

    setUp(() {
      links = StreamController<Uri>();
      billing = FakeBillingRepository();
      assistant = FakeAssistantRepository();
    });

    tearDown(() => links.close());

    Future<ProviderContainer> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(config),
            healthRepositoryProvider.overrideWithValue(
              FakeHealthRepository(() async => readyHealth),
            ),
            agentRepositoryProvider.overrideWithValue(
              FakeAgentRepository(() async => enabledAgent),
            ),
            appSettingsStoreProvider.overrideWithValue(
              await testSettingsStore(language: 'uz'),
            ),
            sessionStoreProvider.overrideWithValue(
              MemorySessionStore(testSession()),
            ),
            initialSessionProvider.overrideWithValue(testSession()),
            incomingLinksProvider.overrideWithValue(links.stream),
            assistantRepositoryProvider.overrideWithValue(assistant),
            voiceRepositoryProvider.overrideWithValue(FakeVoiceRepository()),
            billingRepositoryProvider.overrideWithValue(billing),
          ],
          child: const AlesleApp(),
        ),
      );
      await tester.pumpAndSettle();
      return ProviderScope.containerOf(tester.element(find.byType(AlesleApp)));
    }

    testWidgets('reminds once per period from 80 %', (
      WidgetTester tester,
    ) async {
      billing.current = testBillingStatus(usedPercent: 85);
      final ProviderContainer container = await pumpApp(tester);
      expect(find.byKey(const Key('usage-notice')), findsOneWidget);
      expect(find.text('Bu oylik limitning 85% ishlatildi.'), findsOneWidget);
      expect(
        container.read(appSettingsProvider).usageNoticeKey,
        endsWith(':80'),
      );

      // After a task: checked again, but not told again.
      ScaffoldMessenger.of(tester.element(find.byType(HomeScreen)))
          .removeCurrentSnackBar();
      await tester.pumpAndSettle();
      assistant.push(
        const TaskUpdate(TaskUpdateKind.finished, status: 'done', text: 'ok'),
      );
      await tester.pumpAndSettle();
      expect(
        billing.calls.where((String c) => c == 'status').length,
        greaterThan(1),
      );
      expect(find.byKey(const Key('usage-notice')), findsNothing);
    });

    testWidgets('the reminder opens the plan', (WidgetTester tester) async {
      billing.current = testBillingStatus(usedPercent: 90);
      await pumpApp(tester);
      await tester.tap(find.text('Tarif'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('plan-current')), findsOneWidget);
    });

    testWidgets('a used-up month opens the limit screen once', (
      WidgetTester tester,
    ) async {
      billing.current = testBillingStatus(usedPercent: 100, simple: true);
      await pumpApp(tester);
      expect(find.byType(LimitScreen), findsOneWidget);
      await tester.tap(find.byKey(const Key('limit-close')));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('nothing is said below 80 % or when offline', (
      WidgetTester tester,
    ) async {
      billing.failure = const NetworkFailure();
      await pumpApp(tester);
      expect(find.byKey(const Key('usage-notice')), findsNothing);
      expect(find.byType(LimitScreen), findsNothing);
    });

    testWidgets('a task refused for the limit opens the limit screen', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);
      assistant.push(
        const TaskUpdate(
          TaskUpdateKind.finished,
          status: 'cannot',
          reason: 'daily_limit',
          text: 'Bugungi bepul limit tugadi.',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LimitScreen), findsOneWidget);
      expect(find.text('Bugungi bepul limit tugadi'), findsOneWidget);

      // Back on the result, "add more" opens it again.
      await tester.tap(find.byKey(const Key('limit-later')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('result-add-more')), findsOneWidget);
      await tester.tap(find.byKey(const Key('result-add-more')));
      await tester.pumpAndSettle();
      expect(find.byType(LimitScreen), findsOneWidget);
    });

    testWidgets('the payment page’s way back shows the payment', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);
      links.add(Uri.parse('https://alesle.ai/billing/return?payment=pay-9'));
      await settleFor(tester);
      expect(find.byType(PaymentStatusScreen), findsOneWidget);
      expect(billing.calls, contains('payment:pay-9'));
      expect(find.text('To‘lov qabul qilindi'), findsOneWidget);

      // The same link again does not stack a second screen.
      links.add(Uri.parse('https://alesle.ai/billing/return?payment=pay-9'));
      await settleFor(tester);
      expect(find.byType(PaymentStatusScreen), findsOneWidget);
    });
  });

  group('updates', () {
    late FakeUpdateRepository updates;
    late FakeAssistantRepository assistant;

    setUp(() {
      updates = FakeUpdateRepository();
      assistant = FakeAssistantRepository();
    });

    Future<ProviderContainer> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(config),
            healthRepositoryProvider.overrideWithValue(
              FakeHealthRepository(() async => readyHealth),
            ),
            agentRepositoryProvider.overrideWithValue(
              FakeAgentRepository(() async => enabledAgent),
            ),
            appSettingsStoreProvider.overrideWithValue(
              await testSettingsStore(language: 'uz'),
            ),
            ...signedInOverrides(),
            assistantRepositoryProvider.overrideWithValue(assistant),
            voiceRepositoryProvider.overrideWithValue(FakeVoiceRepository()),
            billingRepositoryProvider.overrideWithValue(
              FakeBillingRepository(),
            ),
            updateRepositoryProvider.overrideWithValue(updates),
            appBuildProvider.overrideWithValue(
              const AppBuild(
                versionCode: 3,
                versionName: '0.3.0',
                certSha256: '',
              ),
            ),
          ],
          child: const AlesleApp(),
        ),
      );
      await settleFor(tester);
      return ProviderScope.containerOf(tester.element(find.byType(AlesleApp)));
    }

    testWidgets('a newer version is offered once', (WidgetTester tester) async {
      updates.newest = testRelease();
      final ProviderContainer container = await pumpApp(tester);
      expect(find.byKey(const Key('update-sheet-title')), findsOneWidget);
      expect(container.read(appSettingsProvider).offeredUpdate, 5);
      await tester.tap(find.byKey(const Key('update-sheet-later')));
      await settleFor(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('"update" from the sheet downloads and installs', (
      WidgetTester tester,
    ) async {
      updates.newest = testRelease();
      await pumpApp(tester);
      await tester.tap(find.byKey(const Key('update-sheet-update')));
      await settleFor(tester);
      expect(find.byType(UpdateScreen), findsOneWidget);
      expect(updates.calls, contains('install:/cache/alesle-5.apk'));
    });

    testWidgets('an offered version is not offered again', (
      WidgetTester tester,
    ) async {
      updates.newest = testRelease();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final AppSettingsStore store = await testSettingsStore(language: 'uz');
      await store.write(store.read().copyWith(offeredUpdate: 5));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(config),
            healthRepositoryProvider.overrideWithValue(
              FakeHealthRepository(() async => readyHealth),
            ),
            agentRepositoryProvider.overrideWithValue(
              FakeAgentRepository(() async => enabledAgent),
            ),
            appSettingsStoreProvider.overrideWithValue(store),
            ...signedInOverrides(),
            assistantRepositoryProvider.overrideWithValue(assistant),
            voiceRepositoryProvider.overrideWithValue(FakeVoiceRepository()),
            billingRepositoryProvider.overrideWithValue(
              FakeBillingRepository(),
            ),
            updateRepositoryProvider.overrideWithValue(updates),
            appBuildProvider.overrideWithValue(
              const AppBuild(
                versionCode: 3,
                versionName: '0.3.0',
                certSha256: '',
              ),
            ),
          ],
          child: const AlesleApp(),
        ),
      );
      await settleFor(tester);
      expect(updates.calls, <String>['latest']);
      expect(find.byKey(const Key('update-sheet-title')), findsNothing);
    });

    testWidgets('a required version leaves only the update screen', (
      WidgetTester tester,
    ) async {
      updates.newest = testRelease(minSupported: 4);
      await pumpApp(tester);
      expect(find.byType(UpdateScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(
        find.text(
          'Davom etish uchun ilovani yangilang. Bir daqiqacha vaqt oladi.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a task refused for an old version shows the update screen', (
      WidgetTester tester,
    ) async {
      await pumpApp(tester);
      assistant.push(
        const TaskUpdate(
          TaskUpdateKind.finished,
          status: 'failed',
          reason: 'upgrade_required',
        ),
      );
      await settleFor(tester);
      expect(find.byType(UpdateScreen), findsOneWidget);
    });

    testWidgets('offline, nothing is offered', (WidgetTester tester) async {
      updates.failure = const NetworkFailure();
      await pumpApp(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    test('a 426 from the API asks for the update', () async {
      final ProviderContainer container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(config),
          sessionStoreProvider.overrideWithValue(MemorySessionStore()),
          appBuildProvider.overrideWithValue(
            const AppBuild(
              versionCode: 1,
              versionName: '0.1.0',
              certSha256: '',
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      for (final Dio dio in <Dio>[
        container.read(dioProvider),
        container.read(anonymousDioProvider),
      ]) {
        DioAdapter(
          dio: dio,
        ).onGet('/v1/me', (server) => server.reply(426, <String, Object?>{}));
        await expectLater(
          dio.get<Object?>('/v1/me'),
          throwsA(isA<DioException>()),
        );
      }
      expect(container.read(upgradeRequiredProvider), isTrue);
      expect(container.read(linkOpenerProvider), isNotNull);
    });
  });
}

final class _SilentConsole implements AgentConsoleRepository {
  @override
  Stream<TaskUpdate> get events => const Stream<TaskUpdate>.empty();

  @override
  Future<String> execute(String actionJson) async => '{}';

  @override
  Future<String> snapshot() async => '{}';

  @override
  Future<TaskStart> startTask(TaskCommand command) async =>
      const TaskStart(started: true);

  @override
  Future<void> stopTask() async {}
}

/// Screens with turning orbs never settle: pump by time.
Future<void> settleFor(WidgetTester tester) async {
  for (int i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
