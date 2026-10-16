import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/app/widgets/alesle_orb.dart';
import 'package:alesle_ai/core/agent/agent_task.dart';
import 'package:alesle_ai/core/api/generated/models/error_code.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/storage/app_settings.dart';
import 'package:alesle_ai/features/home/domain/agent_status.dart';
import 'package:alesle_ai/features/home/domain/home_repositories.dart';
import 'package:alesle_ai/features/home/domain/server_health.dart';
import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:alesle_ai/features/home/presentation/home_screen.dart';
import 'package:flutter/gestures.dart';
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
  late AppSettingsStore settings;

  setUp(() async {
    health = FakeHealthRepository(() async => readyHealth);
    agent = FakeAgentRepository(() async => enabledAgent);
    assistant = FakeAssistantRepository();
    voice = FakeVoiceRepository();
    settings = await testSettingsStore();
  });

  List<Override> overrides({ExecutionPolicy? policy}) => <Override>[
    healthRepositoryProvider.overrideWithValue(health),
    agentRepositoryProvider.overrideWithValue(agent),
    assistantRepositoryProvider.overrideWithValue(assistant),
    voiceRepositoryProvider.overrideWithValue(voice),
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

  group('idle', () {
    testWidgets('greets by the time of day and invites a command', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      expect(find.text('Xayrli kech'), findsOneWidget);
      expect(find.text('Bosing va gapiring'), findsOneWidget);
      expect(find.text('Masalan: “Onamga qo‘ng‘iroq qil”'), findsOneWidget);
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
      expect(find.text('Нажмите и говорите'), findsOneWidget);
      await pumpHome(tester, locale: const Locale('en'));
      expect(find.text('Tap and speak'), findsOneWidget);
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

    testWidgets('the example chip opens the command sheet too', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('example-chip')));
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
      expect(find.text('Bosing va gapiring'), findsOneWidget);
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

  group('voice', () {
    testWidgets('tap to listen, tap to finish: the transcript opens editable', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('orb')));
      await tester.pump();
      expect(voice.starts, 1);
      expect(find.text('Eshityapman'), findsOneWidget);
      expect(
        tester.widget<AlesleOrb>(find.byType(AlesleOrb)).state,
        OrbState.listening,
      );

      await tester.tap(find.byKey(const Key('voice-stop-chip')));
      await tester.pumpAndSettle();
      expect(voice.languages, <String?>['uz']);
      final TextField field = tester.widget(
        find.byKey(const Key('command-field')),
      );
      expect(field.controller?.text, 'Onamga qo‘ng‘iroq qil');

      await tester.enterText(
        find.byKey(const Key('command-field')),
        'Onamga qo‘ng‘iroq qil, iltimos',
      );
      await tester.tap(find.byKey(const Key('send-button')));
      await tester.pump();
      expect(assistant.commands.single.text, 'Onamga qo‘ng‘iroq qil, iltimos');
    });

    testWidgets('hold to talk: listens while held, finishes on release', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      final TestGesture finger = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('orb'))),
      );
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
      await tester.pump();
      expect(voice.starts, 1);
      expect(find.text('Eshityapman'), findsOneWidget);

      await finger.up();
      await tester.pumpAndSettle();
      expect(voice.languages, <String?>['uz']);
      final TextField field = tester.widget(
        find.byKey(const Key('command-field')),
      );
      expect(field.controller?.text, 'Onamga qo‘ng‘iroq qil');
    });

    testWidgets('tells the user when the microphone is not allowed', (
      WidgetTester tester,
    ) async {
      voice.microphone = false;
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('orb')));
      await tester.pump();
      expect(find.text('Mikrofonga ruxsat kerak.'), findsOneWidget);
      expect(voice.starts, 0);
    });

    testWidgets('asks again when nothing was heard', (
      WidgetTester tester,
    ) async {
      voice.heard = const Transcript(text: ' ', language: 'uz', confidence: 0);
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('orb')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('orb')));
      await tester.pumpAndSettle();
      expect(find.text('Eshitmadim. Yana bir bor ayting.'), findsOneWidget);
      expect(find.byKey(const Key('command-field')), findsNothing);
    });

    testWidgets('a too-short tap gives nothing to send', (
      WidgetTester tester,
    ) async {
      voice.heard = null;
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('orb')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('orb')));
      await tester.pumpAndSettle();
      expect(find.text('Eshitmadim. Yana bir bor ayting.'), findsOneWidget);
    });

    testWidgets('says plainly when the speech service is down', (
      WidgetTester tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(find.byKey(const Key('orb')));
      await tester.pump();
      voice.failure = const ServerFailure(
        code: ErrorCode.voiceUnavailable,
        statusCode: 503,
      );
      await tester.tap(find.byKey(const Key('orb')));
      await tester.pumpAndSettle();
      expect(
        find.text('Ovoz xizmati hozir ishlamayapti. Yozib yuboring.'),
        findsOneWidget,
      );
    });

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
