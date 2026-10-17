import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/app/widgets/alesle_orb.dart';
import 'package:alesle_ai/core/agent/agent_task.dart';
import 'package:alesle_ai/core/api/generated/models/error_code.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/storage/app_settings.dart';
import 'package:alesle_ai/features/home/domain/agent_status.dart';
import 'package:alesle_ai/features/home/domain/home_repositories.dart';
import 'package:alesle_ai/features/home/domain/live.dart';
import 'package:alesle_ai/features/home/domain/server_health.dart';
import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:alesle_ai/features/home/presentation/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/pump_app.dart';

void main() {
  late FakeHealthRepository health;
  late FakeAgentRepository agent;
  late FakeAssistantRepository assistant;
  late FakeVoiceRepository voice;
  late FakeHandsFreeRepository listen;
  late AppSettingsStore settings;

  setUp(() async {
    health = FakeHealthRepository(() async => readyHealth);
    agent = FakeAgentRepository(() async => enabledAgent);
    assistant = FakeAssistantRepository();
    voice = FakeVoiceRepository();
    // Live stays off unless a test is about it: the microphone was refused
    // before (settings below), so opening the app neither starts nor asks.
    voice.microphone = false;
    listen = FakeHandsFreeRepository();
    settings = await testSettingsStore();
  });

  List<Override> overrides({ExecutionPolicy? policy}) => <Override>[
    healthRepositoryProvider.overrideWithValue(health),
    agentRepositoryProvider.overrideWithValue(agent),
    assistantRepositoryProvider.overrideWithValue(assistant),
    voiceRepositoryProvider.overrideWithValue(voice),
    handsFreeRepositoryProvider.overrideWithValue(listen),
    appSettingsStoreProvider.overrideWithValue(settings),
    if (policy != null) executionPolicyProvider.overrideWithValue(policy),
  ];

  Future<void> pumpHome(
    WidgetTester tester, {
    ExecutionPolicy? policy,
    DateTime? now,
    Locale locale = const Locale('uz'),
  }) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final DateTime at = now ?? DateTime(2026, 10, 16, 20);
    await pumpLocalized(
      tester,
      HomeScreen(now: () => at),
      overrides: overrides(policy: policy),
      locale: locale,
    );
    await tester.pumpAndSettle();
  }

  /// Opens the command sheet by "type instead", types, and sends.
  Future<void> sendCommand(WidgetTester tester, String text) async {
    await tester.tap(find.byKey(const Key('type-instead')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('command-field')), text);
    await tester.pump();
    await tester.tap(find.byKey(const Key('send-button')));
    // The working orb spins forever: pump, never settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('opening the app', () {
    testWidgets('starts the live conversation by itself, even after the user '
        'ended the last one', (WidgetTester tester) async {
      voice.microphone = true;
      settings = await testSettingsStore(handsFree: false);
      await pumpHome(tester);
      expect(listen.liveLocales, <String>['uz']);
      expect(voice.asks, 0);
      listen.live(const LiveStageChanged(LiveStage.listening));
      await settle(tester);
      expect(find.byKey(const Key('live-view')), findsOneWidget);

      // Coming back to the app starts no second conversation.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await settle(tester);
      expect(listen.liveLocales, hasLength(1));
    });

    testWidgets('asks for the microphone only the first time', (
      WidgetTester tester,
    ) async {
      settings = await testSettingsStore(handsFree: null);
      await pumpHome(tester);
      expect(voice.asks, 1);
      expect(find.text('Mikrofonga ruxsat kerak.'), findsOneWidget);
      expect(settings.read().handsFree, isFalse);
      expect(find.byKey(const Key('home-talk')), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(voice.asks, 1);
      expect(listen.liveLocales, isEmpty);
    });

    testWidgets('with accessibility off it asks for that and does not listen', (
      WidgetTester tester,
    ) async {
      voice.microphone = true;
      agent.next = () async => disabledAgent;
      await pumpHome(tester);
      expect(find.byKey(const Key('off-view')), findsOneWidget);
      expect(listen.liveLocales, isEmpty);
    });
  });

  group('live off', () {
    testWidgets('no push-to-talk, no switch, no personal example: Talk and '
        'typing', (WidgetTester tester) async {
      await pumpHome(tester);
      expect(find.text('Bosing va gapiring'), findsNothing);
      expect(find.byKey(const Key('hands-free-switch')), findsNothing);
      expect(find.textContaining('Onamga'), findsNothing);
      expect(
        find.text('Gaplashish tugmasini bosing yoki yozib yuboring'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('type-instead')), findsOneWidget);

      voice.microphone = true;
      await tester.tap(find.byKey(const Key('home-talk')));
      await settle(tester);
      expect(voice.asks, 1);
      expect(listen.liveLocales, <String>['uz']);
      expect(settings.read().handsFree, isTrue);
    });

    testWidgets('the orb starts the conversation too', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      voice.microphone = true;
      await tester.tap(find.byKey(const Key('orb')));
      await settle(tester);
      expect(listen.liveLocales, <String>['uz']);
    });
  });

  group('when Live is not available', () {
    testWidgets('it listens one command at a time; the orb and the button '
        'mute it', (WidgetTester tester) async {
      voice.microphone = true;
      await pumpHome(tester);
      listen.live(const LiveStageChanged(LiveStage.fallback));
      await settle(tester);
      expect(find.byKey(const Key('live-view')), findsNothing);
      expect(find.text('Tinglayapman — shunchaki gapiring'), findsOneWidget);
      expect(find.byKey(const Key('home-talk')), findsNothing);

      await tester.tap(find.byKey(const Key('orb')));
      await settle(tester);
      expect(listen.mutes, <bool>[true]);
      expect(voice.starts, 0);
      expect(find.text('Mikrofon o‘chiq'), findsWidgets);
      await tester.tap(find.byKey(const Key('hands-free-mute')));
      await settle(tester);
      expect(listen.mutes, <bool>[true, false]);

      voice.heard = const Transcript(
        text: 'Soat ilovasini och',
        language: 'uz',
        confidence: 0.9,
      );
      listen.say('/cache/u.wav');
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(assistant.commands.single.text, 'Soat ilovasini och');
      expect(assistant.commands.single.handsFree, isTrue);
      // Nothing shows until the agent takes a step: background talk leaves no trace.
      expect(find.byKey(const Key('hands-free-running-hint')), findsNothing);
      assistant.push(
        const TaskUpdate(TaskUpdateKind.step, text: 'Soatni ochyapman'),
      );
      await settle(tester);
      expect(find.byKey(const Key('hands-free-running-hint')), findsOneWidget);
    });

    testWidgets('a mumble below confidence shows nothing as heard', (
      WidgetTester tester,
    ) async {
      voice.microphone = true;
      await pumpHome(tester);
      listen.live(const LiveStageChanged(LiveStage.fallback));
      voice.heard = const Transcript(
        text: 'Salom',
        language: 'uz',
        confidence: 0.1,
      );
      listen.say('/cache/u.wav');
      await settle(tester);
      expect(find.byKey(const Key('hands-free-heard')), findsNothing);
    });
  });

  group('live conversation', () {
    testWidgets('like a call: who talks, the words of the turn, phone work as '
        'a chip, and mute, type or end', (WidgetTester tester) async {
      voice.microphone = true;
      settings = await testSettingsStore(handsFree: true);
      await pumpHome(tester);
      expect(listen.liveLocales, hasLength(1));
      expect(find.byKey(const Key('live-view')), findsNothing);

      listen.live(const LiveStageChanged(LiveStage.listening));
      await settle(tester);
      expect(find.byKey(const Key('live-view')), findsOneWidget);
      expect(find.text('Tinglayapman'), findsOneWidget);
      expect(find.text('Gapiring — men shu yerdaman'), findsOneWidget);

      listen
        ..live(const LiveStageChanged(LiveStage.speaking))
        ..live(const LiveCaption(fromUser: true, text: 'Salom', isFinal: true))
        ..live(
          const LiveCaption(
            fromUser: false,
            text: 'Salom! Yordam beraymi?',
            isFinal: false,
          ),
        );
      await settle(tester);
      expect(find.text('Gapiryapman'), findsOneWidget);
      expect(find.text('Salom'), findsNothing);
      expect(find.text('Salom! Yordam beraymi?'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('live-example-0')),
        findsNothing,
      );

      // Phone work: a chip, never the result screen.
      listen.live(const LiveTaskRun(callId: 'c1', command: 'Soatni och'));
      await settle(tester);
      assistant.push(
        const TaskUpdate(TaskUpdateKind.step, text: 'Soatni ochyapman'),
      );
      await settle(tester);
      expect(find.text('Bajaryapman: Soatni ochyapman'), findsOneWidget);
      assistant.push(
        const TaskUpdate(
          TaskUpdateKind.finished,
          status: 'done',
          text: 'Soat ochildi',
        ),
      );
      await settle(tester);
      expect(find.byKey(const Key('live-task')), findsNothing);
      expect(find.byKey(const Key('done-button')), findsNothing);
      expect(voice.spoken, isEmpty);
      expect(listen.taskResults.single, ('c1', 'done', 'Soat ochildi', null));

      await tester.tap(find.byKey(const Key('live-mute')));
      await settle(tester);
      expect(listen.mutes, <bool>[true]);
      expect(find.text('Mikrofon o‘chiq'), findsOneWidget);

      await tester.tap(find.byKey(const Key('live-keyboard')));
      await settle(tester);
      await tester.enterText(find.byKey(const Key('command-field')), 'Rahmat');
      await tester.pump();
      await tester.tap(find.byKey(const Key('send-button')));
      await settle(tester);
      expect(listen.typed, <String>['Rahmat']);

      await tester.tap(find.byKey(const Key('live-close')));
      await settle(tester);
      expect(listen.stops, 1);
      expect(find.byKey(const Key('live-view')), findsNothing);
      expect(find.byKey(const Key('home-talk')), findsOneWidget);
    });

    testWidgets('everyday examples: tapping one says it', (
      WidgetTester tester,
    ) async {
      voice.microphone = true;
      await pumpHome(tester);
      listen.live(const LiveStageChanged(LiveStage.listening));
      await settle(tester);
      expect(find.text('Masalan, ayting:'), findsOneWidget);
      for (int i = 0; i < 3; i++) {
        expect(find.byKey(ValueKey<String>('live-example-$i')), findsOneWidget);
      }
      final Finder first = find.byKey(const ValueKey<String>('live-example-0'));
      final String example = tester
          .widget<Text>(find.descendant(of: first, matching: find.byType(Text)))
          .data!;
      await tester.tap(first);
      await settle(tester);
      expect(listen.typed, <String>[example]);
      expect(
        find.byKey(const ValueKey<String>('live-example-0')),
        findsNothing,
      );
    });

    testWidgets('the orb moves with the voice; a busy microphone is told', (
      WidgetTester tester,
    ) async {
      voice.microphone = true;
      await pumpHome(tester);
      listen.live(const LiveStageChanged(LiveStage.hearing));
      listen.live(const LiveLevel(0.6));
      await settle(tester);
      AlesleOrb orb = tester.widget<AlesleOrb>(find.byType(AlesleOrb));
      expect(orb.level, 0.6);
      expect(orb.state, OrbState.listening);

      listen.report(
        const ListenStatus(active: true, muted: false, paused: true),
      );
      await settle(tester);
      expect(
        find.text('Mikrofon band — bo‘shashini kutyapman'),
        findsOneWidget,
      );
      orb = tester.widget<AlesleOrb>(find.byType(AlesleOrb));
      expect(orb.state, OrbState.idle);

      listen.report(const ListenStatus(active: true, muted: false));
      await settle(tester);
      expect(find.text('Eshityapman…'), findsOneWidget);
    });
  });

  group('idle', () {
    testWidgets('greets by the time of day and invites a command', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      expect(find.text('Xayrli kech'), findsOneWidget);
      expect(find.text('Gaplashish'), findsOneWidget);
      expect(find.byType(AlesleOrb), findsOneWidget);
      expect(find.byKey(const Key('server-problem')), findsNothing);
      expect(find.byKey(const Key('off-view')), findsNothing);
    });

    testWidgets('fits a short screen without overflowing', (
      WidgetTester tester,
    ) async {
      agent.next = () async => disabledAgent;
      await pumpHome(tester);
      tester.view.physicalSize = const Size(2340, 1080);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(AlesleOrb), findsOneWidget);
    });

    testWidgets('morning and afternoon greetings', (WidgetTester tester) async {
      await pumpHome(tester, now: DateTime(2026, 10, 16, 8));
      expect(find.text('Xayrli tong'), findsOneWidget);
      await pumpHome(tester, now: DateTime(2026, 10, 16, 13));
      expect(find.text('Xayrli kun'), findsOneWidget);
    });

    testWidgets('speaks Russian and English', (WidgetTester tester) async {
      await pumpHome(tester, locale: const Locale('ru'));
      expect(find.text('Поговорить'), findsOneWidget);
      await pumpHome(tester, locale: const Locale('en'));
      expect(find.text('Talk'), findsOneWidget);
    });

    testWidgets('asks to turn accessibility on and opens the settings', (
      WidgetTester tester,
    ) async {
      agent.next = () async => disabledAgent;
      await pumpHome(tester);
      expect(find.byKey(const Key('off-view')), findsOneWidget);
      expect(find.text('Alesle o‘chiq'), findsOneWidget);
      expect(find.byKey(const Key('orb')), findsNothing);
      await tester.tap(find.byKey(const Key('enable-accessibility-button')));
      expect(agent.openSettingsCalls, 1);
    });

    testWidgets('re-reads the agent status when the app resumes', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      final int before = agent.statusCalls;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(agent.statusCalls, greaterThan(before));
    });

    testWidgets('shows an agent bridge failure', (WidgetTester tester) async {
      agent.next = () async => throw UnexpectedFailure(Exception('channel'));
      await pumpHome(tester);
      expect(find.byKey(const Key('agent-status-error')), findsOneWidget);
    });

    testWidgets('is quiet about a healthy server, and shows a problem', (
      WidgetTester tester,
    ) async {
      health.next = () async => const ServerHealth(
        dependencies: <String, String>{'database': 'up', 'redis': 'down'},
      );
      await pumpHome(tester);
      expect(find.text('Server bilan aloqa yo‘q'), findsNothing);
      expect(find.byKey(const Key('server-problem')), findsOneWidget);

      health.next = () async => readyHealth;
      await tester.tap(find.text('Qayta urinish'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('server-problem')), findsNothing);
    });

    testWidgets('explains network and server errors in plain words', (
      WidgetTester tester,
    ) async {
      health.next = () async => throw const NetworkFailure();
      await pumpHome(tester);
      expect(find.text('Internet aloqasini tekshiring'), findsOneWidget);

      health.next = () async => throw const ServerFailure(
        code: ErrorCode.serviceUnavailable,
        statusCode: 503,
      );
      await tester.tap(find.text('Qayta urinish'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('server-problem')), findsOneWidget);
    });
  });

  group('a command', () {
    testWidgets('goes out with the locale and the confirmation setting', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      await sendCommand(tester, 'Ertaga 7:30 ga budilnik qo‘y');
      final TaskCommand command = assistant.commands.single;
      expect(command.text, 'Ertaga 7:30 ga budilnik qo‘y');
      expect(command.locale, 'uz');
      expect(command.confirmSensitiveActions, isTrue);
      expect(find.text('Bajaryapman…'), findsOneWidget);
      expect(find.text('Ertaga 7:30 ga budilnik qo‘y'), findsOneWidget);
    });

    testWidgets('carries the countdown setting', (WidgetTester tester) async {
      await pumpHome(tester, policy: ExecutionPolicy.countdown);
      await sendCommand(tester, 'Salom');
      expect(assistant.commands.single.confirmSensitiveActions, isFalse);
    });

    testWidgets('the sheet sends nothing empty, and sends on the keyboard', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('type-instead')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('command-field')), findsOneWidget);
      // Nothing typed: nothing to send.
      final TextButton send = tester.widget(
        find.descendant(
          of: find.byKey(const Key('send-button')),
          matching: find.byType(TextButton),
        ),
      );
      expect(send.onPressed, isNull);
      await tester.enterText(find.byKey(const Key('command-field')), 'Salom');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      expect(assistant.commands.single.text, 'Salom');
    });

    testWidgets('a dismissed sheet starts nothing', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('type-instead')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();
      expect(assistant.commands, isEmpty);
    });

    testWidgets('shows each step and can be stopped', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      await sendCommand(tester, 'Onamga yoz');
      assistant.push(
        const TaskUpdate(TaskUpdateKind.started, text: 'Onamga yoz'),
      );
      assistant.push(
        const TaskUpdate(TaskUpdateKind.step, text: 'Telegram ochilmoqda'),
      );
      await tester.pump();
      expect(find.text('Telegram ochilmoqda'), findsOneWidget);

      await tester.tap(find.byKey(const Key('stop-button')));
      await tester.pump();
      expect(assistant.stops, 1);
    });

    testWidgets('ends done with the agent reply', (WidgetTester tester) async {
      await pumpHome(tester);
      await sendCommand(tester, 'Budilnik 7:30');
      assistant
        ..push(const TaskUpdate(TaskUpdateKind.step, text: 'Budilnik'))
        ..push(
          const TaskUpdate(
            TaskUpdateKind.finished,
            text: 'Budilnik 7:30 ga qo‘yildi',
            status: 'done',
          ),
        );
      await tester.pumpAndSettle();
      expect(find.text('Budilnik 7:30 ga qo‘yildi'), findsOneWidget);
      expect(find.text('Budilnik 7:30'), findsOneWidget);
      expect(
        tester.widget<AlesleOrb>(find.byType(AlesleOrb)).state,
        OrbState.done,
      );

      await tester.tap(find.byKey(const Key('done-button')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home-talk')), findsOneWidget);
    });

    testWidgets('a quick answer shows what was said and the answer', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      await sendCommand(tester, 'Poytaxt qaysi?');
      assistant.push(
        const TaskUpdate(
          TaskUpdateKind.finished,
          text: 'Toshkent',
          status: 'done',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Siz aytdingiz'), findsOneWidget);
      expect(find.text('“Poytaxt qaysi?”'), findsOneWidget);
      expect(find.byKey(const Key('quick-answer')), findsOneWidget);
    });

    testWidgets('a failure explains why, in plain words', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      await sendCommand(tester, 'Telegramda yoz');
      assistant.push(
        const TaskUpdate(
          TaskUpdateKind.finished,
          status: 'failed',
          reason: 'stuck',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Bajarib bo‘lmadi'), findsOneWidget);
      expect(find.text('Ekranda kerakli joyni topa olmadim.'), findsOneWidget);
      expect(
        tester.widget<AlesleOrb>(find.byType(AlesleOrb)).state,
        OrbState.notDone,
      );
    });

    testWidgets('a refused start is shown as not done', (
      WidgetTester tester,
    ) async {
      assistant.nextStart = const TaskStart(
        started: false,
        reason: 'not_signed_in',
      );
      await pumpHome(tester);
      await sendCommand(tester, 'Salom');
      await tester.pumpAndSettle();
      expect(find.text('Avval tizimga kiring.'), findsOneWidget);
    });

    testWidgets('a platform failure is shown as not done', (
      WidgetTester tester,
    ) async {
      assistant.failure = UnexpectedFailure(Exception('channel'));
      await pumpHome(tester);
      await sendCommand(tester, 'Salom');
      await tester.pumpAndSettle();
      expect(
        find.text('Nimadir xato ketdi. Qaytadan urinib ko‘ring.'),
        findsOneWidget,
      );
    });

    testWidgets('a stopped task says so without blame', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      await sendCommand(tester, 'Salom');
      assistant.push(
        const TaskUpdate(
          TaskUpdateKind.finished,
          status: 'stopped',
          reason: 'user_stopped',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('To‘xtatildi'), findsOneWidget);
      expect(find.byKey(const Key('result-explanation')), findsNothing);
    });
  });

  group('spoken replies', () {
    testWidgets('reads the reply aloud', (WidgetTester tester) async {
      await pumpHome(tester);
      await sendCommand(tester, 'Poytaxt?');
      assistant.push(
        const TaskUpdate(
          TaskUpdateKind.finished,
          text: 'Toshkent',
          status: 'done',
        ),
      );
      await tester.pumpAndSettle();
      expect(voice.spoken, <String>['Toshkent']);
    });

    testWidgets('stays silent when the user turned voice replies off', (
      WidgetTester tester,
    ) async {
      settings = await testSettingsStore(voiceReplies: false);
      await pumpHome(tester);
      await sendCommand(tester, 'Poytaxt?');
      assistant.push(
        const TaskUpdate(
          TaskUpdateKind.finished,
          text: 'Toshkent',
          status: 'done',
        ),
      );
      await tester.pumpAndSettle();
      expect(voice.spoken, isEmpty);
    });

    testWidgets('a reply that cannot be spoken stays quiet', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      await sendCommand(tester, 'Salom');
      voice.failure = const NetworkFailure();
      assistant.push(
        const TaskUpdate(
          TaskUpdateKind.finished,
          text: 'Salom',
          status: 'done',
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
