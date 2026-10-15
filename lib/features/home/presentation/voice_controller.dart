import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../data/home_data_providers.dart';
import '../domain/home_repositories.dart';

enum VoicePhase { idle, listening, transcribing }

/// Why push-to-talk produced no command, for a one-line message.
enum VoiceProblem { microphoneDenied, notHeard, failed }

final class VoiceState {
  const VoiceState({this.phase = VoicePhase.idle, this.problem, this.failure});

  final VoicePhase phase;
  final VoiceProblem? problem;

  /// The failure behind [VoiceProblem.failed], for its message.
  final Failure? failure;
}

/// Tap to speak, tap again to finish (SOW 04 §4.1, design "Listening").
class VoiceController extends Notifier<VoiceState> {
  VoiceRepository get _voice => ref.read(voiceRepositoryProvider);

  @override
  VoiceState build() => const VoiceState();

  /// Starts listening, or finishes and returns what was heard; null when
  /// there is nothing to send (still listening, nothing heard, or a problem).
  Future<String?> toggle({String? language}) async {
    switch (state.phase) {
      case VoicePhase.transcribing:
        return null;
      case VoicePhase.idle:
        await _start();
        return null;
      case VoicePhase.listening:
        return _finish(language);
    }
  }

  Future<void> cancel() async {
    if (state.phase != VoicePhase.listening) return;
    state = const VoiceState();
    try {
      await _voice.cancelListening();
    } on Failure {
      // Nothing was recording any more.
    }
  }

  void clearProblem() => state = VoiceState(phase: state.phase);

  Future<void> _start() async {
    try {
      if (!await _voice.ensureMicrophone()) {
        state = const VoiceState(problem: VoiceProblem.microphoneDenied);
        return;
      }
      await _voice.startListening();
      state = const VoiceState(phase: VoicePhase.listening);
    } on Failure catch (failure) {
      state = VoiceState(problem: VoiceProblem.failed, failure: failure);
    }
  }

  Future<String?> _finish(String? language) async {
    state = const VoiceState(phase: VoicePhase.transcribing);
    try {
      final Transcript? transcript = await _voice.finishListening(
        language: language,
      );
      final String text = transcript?.text.trim() ?? '';
      if (text.isEmpty) {
        state = const VoiceState(problem: VoiceProblem.notHeard);
        return null;
      }
      state = const VoiceState();
      return text;
    } on Failure catch (failure) {
      state = VoiceState(problem: VoiceProblem.failed, failure: failure);
      return null;
    }
  }
}

final NotifierProvider<VoiceController, VoiceState> voiceProvider =
    NotifierProvider<VoiceController, VoiceState>(VoiceController.new);
