import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/home/data/home_data_providers.dart';
import 'package:alesle_ai/features/home/domain/home_repositories.dart';
import 'package:alesle_ai/features/home/presentation/voice_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fakes.dart';

void main() {
  late FakeVoiceRepository voice;
  late ProviderContainer container;

  setUp(() {
    voice = FakeVoiceRepository();
    container = ProviderContainer(
      overrides: [voiceRepositoryProvider.overrideWithValue(voice)],
    );
    addTearDown(container.dispose);
  });

  VoiceController controller() => container.read(voiceProvider.notifier);
  VoiceState state() => container.read(voiceProvider);

  test('tap listens, second tap returns what was heard', () async {
    expect(await controller().toggle(), isNull);
    expect(state().phase, VoicePhase.listening);
    expect(voice.starts, 1);

    expect(await controller().toggle(language: 'uz'), 'Onamga qo‘ng‘iroq qil');
    expect(state().phase, VoicePhase.idle);
    expect(state().problem, isNull);
    expect(voice.languages, <String?>['uz']);
  });

  test('no microphone: a problem, not listening', () async {
    voice.microphone = false;
    await controller().toggle();
    expect(state().phase, VoicePhase.idle);
    expect(state().problem, VoiceProblem.microphoneDenied);
    expect(voice.starts, 0);
    controller().clearProblem();
    expect(state().problem, isNull);
  });

  test('silence or a too-short recording: not heard', () async {
    await controller().toggle();
    voice.heard = const Transcript(
      text: '  ',
      language: 'other',
      confidence: 0,
    );
    expect(await controller().toggle(), isNull);
    expect(state().problem, VoiceProblem.notHeard);

    await controller().toggle();
    voice.heard = null;
    expect(await controller().toggle(), isNull);
    expect(state().problem, VoiceProblem.notHeard);
  });

  test('a failure while starting or transcribing is reported', () async {
    voice.failure = const NetworkFailure();
    await controller().toggle();
    expect(state().problem, VoiceProblem.failed);
    expect(state().failure, isA<NetworkFailure>());

    voice.failure = null;
    await controller().toggle();
    voice.failure = const NetworkFailure();
    expect(await controller().toggle(), isNull);
    expect(state().problem, VoiceProblem.failed);
  });

  test('cancel stops listening; ignored when idle', () async {
    await controller().cancel();
    expect(voice.cancels, 0);
    await controller().toggle();
    await controller().cancel();
    expect(state().phase, VoicePhase.idle);
    expect(voice.cancels, 1);
  });

  test('a tap while transcribing does nothing', () async {
    await controller().toggle();
    final Future<String?> finishing = controller().toggle();
    expect(state().phase, VoicePhase.transcribing);
    expect(await controller().toggle(), isNull);
    expect(await finishing, isNotNull);
  });
}
