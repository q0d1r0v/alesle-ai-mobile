import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/agent/agent_task.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/storage/app_settings.dart';
import 'package:alesle_ai/features/home/domain/home_repositories.dart';
import 'package:alesle_ai/features/home/presentation/hands_free_controller.dart';
import 'package:alesle_ai/features/home/presentation/home_providers.dart';
import 'package:alesle_ai/features/home/presentation/home_task_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late FakeHandsFreeRepository listen;
  late FakeVoiceRepository voice;
  late FakeAssistantRepository assistant;
  late AppSettingsStore settings;
  late ProviderContainer container;

  setUp(() async {
    listen = FakeHandsFreeRepository();
    voice = FakeVoiceRepository();
    assistant = FakeAssistantRepository();
    settings = await testSettingsStore();
    container = ProviderContainer(
      overrides: [
        handsFreeRepositoryProvider.overrideWithValue(listen),
        voiceRepositoryProvider.overrideWithValue(voice),
        assistantRepositoryProvider.overrideWithValue(assistant),
        appSettingsStoreProvider.overrideWithValue(settings),
      ],
    );
    addTearDown(container.dispose);
    // Subscribe, as the home screen does.
    container.listen(handsFreeProvider, (_, _) {});
    container.listen(homeTaskProvider, (_, _) {});
  });

  HandsFreeController controller() =>
      container.read(handsFreeProvider.notifier);
  HandsFreeState state() => container.read(handsFreeProvider);
  Future<void> flush() async {
    for (int i = 0; i < 5; i++) {
      await Future<void>.delayed(Duration.zero);
    }
  }

  void hear(String text, {String language = 'uz', double confidence = 0.9}) {
    voice.heard = Transcript(
      text: text,
      language: language,
      confidence: confidence,
    );
    listen.say('/cache/u-$text.wav');
  }

  test('turning on listens and is remembered; off forgets it', () async {
    await controller().turnOn(appLocale: 'uz');
    expect(state().phase, HandsFreePhase.listening);
    expect(settings.read().handsFree, isTrue);
    await controller().turnOff();
    expect(state().phase, HandsFreePhase.off);
    expect(listen.stops, 1);
    expect(settings.read().handsFree, isFalse);
  });

  test(
    'no microphone permission or a dead service: a problem, still off',
    () async {
      voice.microphone = false;
      await controller().turnOn(appLocale: 'uz');
      expect(state().problem, HandsFreeProblem.microphoneDenied);
      expect(state().on, isFalse);
      controller().clearProblem();
      expect(state().problem, isNull);

      voice.microphone = true;
      listen.startWorks = false;
      await controller().turnOn(appLocale: 'uz');
      expect(state().problem, HandsFreeProblem.startFailed);

      listen.failure = const UnexpectedFailure('x');
      await controller().turnOn(appLocale: 'uz');
      expect(state().problem, HandsFreeProblem.startFailed);
      await controller().turnOff();
      expect(state().on, isFalse);
    },
  );

  test(
    'what is said with no task running starts one, in the language heard',
    () async {
      await controller().turnOn(appLocale: 'uz');
      hear('Включи будильник на семь', language: 'ru');
      await flush();
      final TaskCommand command = assistant.commands.single;
      expect(command.text, 'Включи будильник на семь');
      expect(command.locale, 'ru');
      expect(command.confirmSensitiveActions, isTrue);
      expect(state().heard, 'Включи будильник на семь');
      expect(state().phase, HandsFreePhase.listening);
      expect(voice.transcribed, <String>[
        '/cache/u-Включи будильник на семь.wav',
      ]);
    },
  );

  test('while a task runs, words change it and "to\'xta" stops it', () async {
    await controller().turnOn(appLocale: 'uz');
    hear('Soat ilovasini och');
    await flush();
    expect(container.read(homeTaskProvider.notifier).busy, isTrue);

    hear('buni ham qilib ket: sekundomerni yoq');
    await flush();
    expect(assistant.amendments, <String>[
      'buni ham qilib ket: sekundomerni yoq',
    ]);
    expect(assistant.commands, hasLength(1));

    hear("To'xta!");
    await flush();
    expect(assistant.stops, 1);
    expect(assistant.amendments, hasLength(1));
  });

  test('a task that just ended takes the words as a new command', () async {
    await controller().turnOn(appLocale: 'en');
    hear('Open the clock', language: 'en');
    await flush();
    assistant.amendAccepted = false;
    hear('Now open the calendar', language: 'other');
    await flush();
    expect(assistant.commands.map((TaskCommand c) => c.text), <String>[
      'Open the clock',
      'Now open the calendar',
    ]);
    // Heard in an unknown language: the app's language answers.
    expect(assistant.commands.last.locale, 'en');
  });

  test('noise, silence, a bare stop with nothing running, and failures are ignored', () async {
    await controller().turnOn(appLocale: 'uz');
    hear('   ');
    hear('mmm', confidence: 0.1);
    hear('stop');
    await flush();
    voice.failure = const NetworkFailure();
    listen.say('/cache/x.wav');
    await flush();
    expect(assistant.commands, isEmpty);
    expect(state().phase, HandsFreePhase.listening);
  });

  test('mute, unmute, and the service state wins', () async {
    await controller().toggleMute();
    expect(listen.mutes, isEmpty); // Off: nothing to mute.
    await controller().turnOn(appLocale: 'uz');
    await controller().toggleMute();
    expect(state().phase, HandsFreePhase.muted);
    await controller().toggleMute();
    expect(state().phase, HandsFreePhase.listening);
    expect(listen.mutes, <bool>[true, false]);

    // Muted from the notification.
    listen.report(const ListenStatus(active: true, muted: true));
    await flush();
    expect(state().phase, HandsFreePhase.muted);
    // Turned off from the notification.
    listen.report(ListenStatus.off);
    await flush();
    expect(state().on, isFalse);

    listen.failure = const UnexpectedFailure('x');
    await controller().toggleMute();
    expect(state().on, isFalse);
  });

  test(
    'resume: on unless turned off, never asking for the microphone',
    () async {
      // Turned off by the user: stays off.
      await controller().resume(appLocale: 'uz');
      expect(listen.starts, 0);

      // Never chosen: on by itself, with the microphone already allowed.
      await settings.write(const AppSettings(onboardingDone: true));
      container.invalidate(appSettingsProvider);
      expect(container.read(appSettingsProvider).handsFree, isNull);
      await controller().resume(appLocale: 'uz');
      expect(listen.starts, 1);
      expect(state().phase, HandsFreePhase.listening);

      // Already listening (muted from the notification): just shows it.
      listen.current = const ListenStatus(active: true, muted: true);
      await controller().resume(appLocale: 'uz');
      expect(listen.starts, 1);
      expect(state().phase, HandsFreePhase.muted);

      // No microphone permission yet: stays off and asks nothing.
      listen.current = ListenStatus.off;
      voice.microphone = false;
      await controller().resume(appLocale: 'uz');
      expect(listen.starts, 1);
      expect(voice.grantedChecks, greaterThan(0));

      // A failing service: quietly off, no message.
      voice.microphone = true;
      listen.failure = const UnexpectedFailure('x');
      await controller().resume(appLocale: 'uz');
      expect(state().problem, isNull);
    },
  );
}
