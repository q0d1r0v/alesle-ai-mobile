import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/core_providers.dart';
import '../../../core/agent/agent_task.dart';
import '../../../core/errors/failure.dart';
import '../domain/agent_status.dart';
import '../domain/hands_free.dart';
import '../domain/home_repositories.dart';
import '../domain/live.dart';
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

/// Why hands-free could not start or go on, for a one-line message.
enum HandsFreeProblem { microphoneDenied, startFailed, limitReached }

final class HandsFreeState {
  const HandsFreeState({
    this.phase = HandsFreePhase.off,
    this.heard,
    this.problem,
    this.live,
    this.said,
    this.reply,
  });

  final HandsFreePhase phase;

  /// The last thing understood, shown so the user sees what was taken.
  final String? heard;
  final HandsFreeProblem? problem;

  /// Where the live conversation is; null when there is none.
  final LiveStage? live;

  /// What the user typed into the live conversation, this turn. Spoken
  /// words are not shown: the model's transcript of Uzbek is unreliable.
  final String? said;

  /// Alesle's words in the live conversation, this turn.
  final String? reply;

  bool get on => phase != HandsFreePhase.off;

  /// The screen shows the conversation, not the one-command-at-a-time home.
  bool get inConversation => on && live != null && live != LiveStage.fallback;

  HandsFreeState copyWith({
    HandsFreePhase? phase,
    String? heard,
    HandsFreeProblem? problem,
    bool clearProblem = false,
    LiveStage? live,
    String? said,
    String? reply,
    bool clearReply = false,
    bool clearSaid = false,
  }) => HandsFreeState(
    phase: phase ?? this.phase,
    heard: heard ?? this.heard,
    problem: clearProblem ? null : (problem ?? this.problem),
    live: live ?? this.live,
    said: clearSaid ? null : (said ?? this.said),
    reply: clearReply ? null : (reply ?? this.reply),
  );
}

/// Hands-free (SOW 04 §4.3): the phone listens all the time. Normally it is a
/// live conversation (§4.2): Alesle hears speech as it comes, answers by
/// voice, can be talked over, and asks the agent for phone work itself.
/// When Live is not available, what the user says starts a command, or —
/// while one runs — changes it, answers its question or stops it. Nothing to
/// press; mute when others are talking.
class HandsFreeController extends Notifier<HandsFreeState> {
  HandsFreeRepository get _listen => ref.read(handsFreeRepositoryProvider);
  VoiceRepository get _voice => ref.read(voiceRepositoryProvider);

  /// The app's language, for replies when the speech service cannot tell.
  String _appLocale = 'uz';

  /// Utterances are handled one at a time, in the order they were said.
  Future<void> _queue = Future<void>.value();

  /// Below this the speech service is guessing at noise.
  static const double minConfidence = 0.3;

  /// The live conversation's request the running task answers.
  String? _liveCall;

  /// Requests the model made while a task ran: (callId, command), in order.
  /// One task works the screen at a time; the next starts when it ends.
  final List<(String, String)> _waiting = <(String, String)>[];

  /// Changes heard with no task running, started as tasks of their own.
  int _amendCalls = 0;

  /// Alesle's last words closed their turn: the next words start a new one.
  bool _replyDone = false;

  @override
  HandsFreeState build() {
    final HandsFreeRepository listen = ref.watch(handsFreeRepositoryProvider);
    final List<StreamSubscription<Object>> subscriptions =
        <StreamSubscription<Object>>[
          listen.statusChanges.listen(_onStatus),
          listen.utterances.listen(
            (String path) => _queue = _queue.then((_) => _onUtterance(path)),
          ),
          listen.liveUpdates.listen(_onLive),
          ref.watch(assistantRepositoryProvider).updates.listen(_onTask),
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
    final ListenStatus status = await _listen.startLive(locale: _appLocale);
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

  /// Typed into the live conversation.
  Future<void> sendText(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _listen.sendLiveText(text.trim());
      state = state.copyWith(said: text.trim(), clearReply: true);
    } on Failure {
      // Gone with the connection; the stage says so.
    }
  }

  void _onLive(LiveUpdate update) {
    if (!state.on) return;
    switch (update) {
      case LiveStageChanged(stage: LiveStage.unauthorized):
        unawaited(_listen.refreshLiveToken().catchError((Object _) {}));
      case LiveStageChanged(stage: LiveStage.limitReached):
        state = HandsFreeState(
          phase: state.phase,
          heard: state.heard,
          problem: HandsFreeProblem.limitReached,
        );
      case LiveStageChanged(:final LiveStage stage):
        state = state.copyWith(live: stage);
      case LiveCaption(fromUser: true):
        // A new turn starts clean.
        if (!_replyDone) return;
        _replyDone = false;
        state = state.copyWith(clearReply: true, clearSaid: true);
      case LiveCaption(
        fromUser: false,
        :final String text,
        :final bool isFinal,
      ):
        _replyDone = isFinal;
        state = state.copyWith(reply: text);
      case LiveTaskRun(:final String callId, :final String command):
        unawaited(_runForLive(callId, command));
      case LiveTaskAmend(:final String text):
        unawaited(_amendForLive(text));
      case LiveTaskStop():
        _waiting.clear();
        unawaited(ref.read(homeTaskProvider.notifier).stop());
      case LiveEnded():
        unawaited(turnOff());
    }
  }

  /// The model heard a change to the task; with none running it is a new one
  /// (its end is told to the model under an id it does not know, in words).
  Future<void> _amendForLive(String text) async {
    bool amended;
    try {
      amended = await ref.read(assistantRepositoryProvider).amend(text);
    } on Failure {
      return;
    }
    if (amended) return;
    await _runForLive('amend-${++_amendCalls}', text);
  }

  Future<void> _runForLive(String callId, String command) async {
    if (_liveCall != null) {
      _waiting.add((callId, command));
      return;
    }
    // Taken before the await: a request that comes meanwhile waits its turn.
    _liveCall = callId;
    final TaskStart start = await ref
        .read(homeTaskProvider.notifier)
        .start(
          TaskCommand(
            text: command,
            locale: _appLocale,
            confirmSensitiveActions:
                ref.read(executionPolicyProvider) ==
                ExecutionPolicy.confirmSensitiveActions,
            handsFree: true,
            direct: true,
          ),
        );
    if (start.started) return;
    _liveCall = null;
    if (start.reason == 'already_running') {
      // A task started from the screen runs: this one goes when it ends.
      _waiting.insert(0, (callId, command));
      return;
    }
    await _report(callId, 'failed', reason: start.reason);
  }

  void _onTask(TaskUpdate update) {
    if (update.kind != TaskUpdateKind.finished) return;
    final String? callId = _liveCall;
    _liveCall = null;
    if (callId != null) {
      unawaited(
        _report(
          callId,
          update.status ?? 'failed',
          reply: update.text,
          reason: update.reason,
        ),
      );
    }
    // After the task screen has settled on this end, the next one starts.
    if (_waiting.isNotEmpty) unawaited(Future<void>(_startNext));
  }

  Future<void> _startNext() async {
    if (_waiting.isEmpty || _liveCall != null || !state.on) return;
    final (String callId, String command) = _waiting.removeAt(0);
    await _runForLive(callId, command);
  }

  Future<void> _report(
    String callId,
    String status, {
    String? reply,
    String? reason,
  }) async {
    try {
      await _listen.liveTaskResult(
        callId,
        status: status,
        reply: reply,
        reason: reason,
      );
    } on Failure {
      // The conversation is gone; nobody is waiting for it.
    }
  }

  void _onStatus(ListenStatus status) {
    if (!status.active) {
      _liveCall = null;
      _waiting.clear();
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
