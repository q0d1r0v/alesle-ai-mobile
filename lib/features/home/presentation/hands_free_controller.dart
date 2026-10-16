import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/core_providers.dart';
import '../../../core/agent/agent_task.dart';
import '../../../core/errors/failure.dart';
import '../domain/agent_status.dart';
import '../domain/hands_free.dart';
import '../domain/home_repositories.dart';
import 'home_providers.dart';
import 'home_task_controller.dart';

enum HandsFreePhase {
  off,

  /// The microphone is open; just speak.
  listening,

  /// Open but muted by the user: nothing is heard.
  muted,

  /// An utterance is being turned into text.
  understanding,
}

/// Why hands-free could not start, for a one-line message.
enum HandsFreeProblem { microphoneDenied, startFailed }

final class HandsFreeState {
  const HandsFreeState({
    this.phase = HandsFreePhase.off,
    this.heard,
    this.problem,
  });

  final HandsFreePhase phase;

  /// The last thing understood, shown so the user sees what was taken.
  final String? heard;
  final HandsFreeProblem? problem;

  bool get on => phase != HandsFreePhase.off;

  HandsFreeState copyWith({
    HandsFreePhase? phase,
    String? heard,
    HandsFreeProblem? problem,
    bool clearProblem = false,
  }) => HandsFreeState(
    phase: phase ?? this.phase,
    heard: heard ?? this.heard,
    problem: clearProblem ? null : (problem ?? this.problem),
  );
}

/// Hands-free (SOW 04 §4.3): the phone listens all the time, and what the
/// user says starts a command, or — while one runs — changes it, answers its
/// question or stops it. Nothing to press; mute when others are talking.
class HandsFreeController extends Notifier<HandsFreeState> {
  HandsFreeRepository get _listen => ref.read(handsFreeRepositoryProvider);
  VoiceRepository get _voice => ref.read(voiceRepositoryProvider);

  /// The app's language, for replies when the speech service cannot tell.
  String _appLocale = 'uz';

  /// Utterances are handled one at a time, in the order they were said.
  Future<void> _queue = Future<void>.value();

  /// Below this the speech service is guessing at noise.
  static const double minConfidence = 0.3;

  @override
  HandsFreeState build() {
    final HandsFreeRepository listen = ref.watch(handsFreeRepositoryProvider);
    final List<StreamSubscription<Object>> subscriptions =
        <StreamSubscription<Object>>[
          listen.statusChanges.listen(_onStatus),
          listen.utterances.listen(
            (String path) => _queue = _queue.then((_) => _onUtterance(path)),
          ),
        ];
    ref.onDispose(() {
      for (final StreamSubscription<Object> subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
    });
    return const HandsFreeState();
  }

  /// Turns hands-free on (and remembers it). The app must be in front.
  Future<void> turnOn({required String appLocale}) async {
    _appLocale = appLocale;
    try {
      if (!await _voice.ensureMicrophone()) {
        state = state.copyWith(problem: HandsFreeProblem.microphoneDenied);
        return;
      }
      if (!await _startListening()) {
        state = state.copyWith(problem: HandsFreeProblem.startFailed);
        return;
      }
      await _remember(on: true);
    } on Failure {
      state = state.copyWith(problem: HandsFreeProblem.startFailed);
    }
  }

  Future<bool> _startListening() async {
    final ListenStatus status = await _listen.start();
    if (!status.active) return false;
    _onStatus(status);
    return true;
  }

  Future<void> turnOff() async {
    try {
      await _listen.stop();
    } on Failure {
      // Already gone.
    }
    state = const HandsFreeState();
    await _remember(on: false);
  }

  /// Back in the app: hands-free is on unless the user turned it off. It
  /// listens again only with the microphone already allowed: opening the app
  /// never pops a permission dialog (the switch asks).
  Future<void> resume({required String appLocale}) async {
    _appLocale = appLocale;
    if (ref.read(appSettingsProvider).handsFree == false) return;
    try {
      final ListenStatus status = await _listen.status();
      if (status.active) {
        _onStatus(status);
        return;
      }
      if (!await _voice.microphoneGranted()) return;
      await _startListening();
    } on Failure {
      // Quietly off; the switch still works.
    }
  }

  Future<void> toggleMute() async {
    if (!state.on) return;
    final bool mute = state.phase != HandsFreePhase.muted;
    try {
      await _listen.setMuted(mute);
      state = state.copyWith(
        phase: mute ? HandsFreePhase.muted : HandsFreePhase.listening,
      );
    } on Failure {
      // The notification still mutes; the next status event corrects us.
    }
  }

  void clearProblem() => state = state.copyWith(clearProblem: true);

  void _onStatus(ListenStatus status) {
    if (!status.active) {
      state = HandsFreeState(problem: state.problem);
      return;
    }
    if (state.phase == HandsFreePhase.understanding && !status.muted) return;
    state = state.copyWith(
      phase: status.muted ? HandsFreePhase.muted : HandsFreePhase.listening,
    );
  }

  Future<void> _onUtterance(String path) async {
    final HandsFreePhase before = state.phase;
    state = state.copyWith(phase: HandsFreePhase.understanding);
    try {
      final Transcript heard = await _voice.transcribeFile(path);
      final String text = heard.text.trim();
      if (text.isNotEmpty && heard.confidence >= minConfidence) {
        state = state.copyWith(heard: text);
        await _act(text, heard.language);
      }
    } on Failure {
      // Not understood (or offline): keep listening; the user says it again.
    } finally {
      if (state.phase == HandsFreePhase.understanding) {
        state = state.copyWith(
          phase: before == HandsFreePhase.muted
              ? HandsFreePhase.muted
              : HandsFreePhase.listening,
        );
      }
    }
  }

  Future<void> _act(String text, String language) async {
    final HomeTaskController tasks = ref.read(homeTaskProvider.notifier);
    if (tasks.busy) {
      if (isStopCommand(text)) {
        await tasks.stop();
        return;
      }
      // Changes the running task, or answers the question on screen.
      if (await ref.read(assistantRepositoryProvider).amend(text)) return;
      // The phone says nothing runs any more: the screen is behind; start afresh.
      tasks.dismiss();
    }
    if (isStopCommand(text)) return;
    await tasks.start(
      TaskCommand(
        text: text,
        locale: replyLocale(language, _appLocale),
        confirmSensitiveActions:
            ref.read(executionPolicyProvider) ==
            ExecutionPolicy.confirmSensitiveActions,
        handsFree: true,
      ),
    );
  }

  Future<void> _remember({required bool on}) => ref
      .read(appSettingsProvider.notifier)
      .update((settings) => settings.copyWith(handsFree: on));
}

final NotifierProvider<HandsFreeController, HandsFreeState> handsFreeProvider =
    NotifierProvider<HandsFreeController, HandsFreeState>(
      HandsFreeController.new,
    );
