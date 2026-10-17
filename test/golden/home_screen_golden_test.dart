@Tags(<String>['golden'])
library;

import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/storage/app_settings.dart';
import 'package:alesle_ai/features/home/domain/live.dart';
import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:alesle_ai/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/pump_app.dart';

/// Update after an intentional UI change:
///   flutter test --tags golden --update-goldens
void main() {
  late AppSettingsStore settings;

  setUp(() async => settings = await testSettingsStore());

  Future<void> pumpAt(
    WidgetTester tester,
    FakeAgentRepository agent, {
    FakeHandsFreeRepository? listen,
    bool microphone = false,
  }) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      // A fixed evening: the greeting follows the clock.
      HomeScreen(now: () => DateTime(2026, 10, 16, 20)),
      overrides: [
        assistantRepositoryProvider.overrideWithValue(
          FakeAssistantRepository(),
        ),
        healthRepositoryProvider.overrideWithValue(
          FakeHealthRepository(() async => readyHealth),
        ),
        agentRepositoryProvider.overrideWithValue(agent),
        appSettingsStoreProvider.overrideWithValue(settings),
        handsFreeRepositoryProvider.overrideWithValue(
          listen ?? FakeHandsFreeRepository(),
        ),
        voiceRepositoryProvider.overrideWithValue(
          FakeVoiceRepository()..microphone = microphone,
        ),
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

  testWidgets('home — live, listening, with examples', (
    WidgetTester tester,
  ) async {
    final FakeHandsFreeRepository listen = FakeHandsFreeRepository();
    await pumpAt(
      tester,
      FakeAgentRepository(() async => enabledAgent),
      listen: listen,
      microphone: true,
    );
    listen.live(const LiveStageChanged(LiveStage.listening));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_live_examples.png'),
    );
  });

  testWidgets('home — live conversation', (WidgetTester tester) async {
    settings = await testSettingsStore(handsFree: true);
    final FakeHandsFreeRepository listen = FakeHandsFreeRepository();
    await pumpAt(
      tester,
      FakeAgentRepository(() async => enabledAgent),
      listen: listen,
      microphone: true,
    );
    listen
      ..live(const LiveStageChanged(LiveStage.speaking))
      ..live(
        const LiveCaption(
          fromUser: true,
          text: 'Ertaga havo qanaqa bo‘ladi?',
          isFinal: true,
        ),
      )
      ..live(
        const LiveCaption(
          fromUser: false,
          text: 'Ertaga Toshkentda quyoshli, kunduzi 18 daraja.',
          isFinal: false,
        ),
      );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await expectLater(
      find.byType(HomeScreen),
      matchesGoldenFile('goldens/home_live.png'),
    );
  });
}
