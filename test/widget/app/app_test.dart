import 'dart:async';

import 'package:alesle_ai/app/account_links.dart';
import 'package:alesle_ai/app/app.dart';
import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/api/generated/models/error_code.dart';
import 'package:alesle_ai/core/auth/session_store.dart';
import 'package:alesle_ai/core/config/app_config.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/agent_debug/data/agent_debug_data_providers.dart';
import 'package:alesle_ai/features/agent_debug/domain/agent_console.dart';
import 'package:alesle_ai/features/agent_debug/presentation/agent_debug_screen.dart';
import 'package:alesle_ai/features/auth/data/auth_data_providers.dart';
import 'package:alesle_ai/features/auth/presentation/sign_in_screen.dart';
import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:alesle_ai/features/home/presentation/home_screen.dart';
import 'package:alesle_ai/features/onboarding/data/onboarding_data_providers.dart';
import 'package:alesle_ai/features/onboarding/presentation/onboarding_screen.dart';
import 'package:alesle_ai/features/settings/data/settings_data_providers.dart';
import 'package:alesle_ai/features/settings/domain/account.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
