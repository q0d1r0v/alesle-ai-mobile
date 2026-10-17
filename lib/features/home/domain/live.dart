/// The live conversation (SOW 04 §4.2): what the phone reports while the
/// user talks with Alesle in real time. Pure Dart.
library;

/// Where the conversation is.
enum LiveStage {
  /// Opening the connection.
  connecting,

  /// Ready: just speak.
  listening,

  /// The user is speaking.
  hearing,

  /// The user stopped; the answer is on its way.
  thinking,

  /// Alesle is speaking.
  speaking,

  /// Live is not available now: hands-free takes one command at a time.
  fallback,

  /// The plan's credits are used up.
  limitReached,

  /// The token was refused: a fresh one is needed.
  unauthorized,
}

sealed class LiveUpdate {
  const LiveUpdate();
}

final class LiveStageChanged extends LiveUpdate {
  const LiveStageChanged(this.stage);

  final LiveStage stage;

  @override
  bool operator ==(Object other) =>
      other is LiveStageChanged && other.stage == stage;

  @override
  int get hashCode => stage.hashCode;
}

/// What was said so far in this turn, by the user or by Alesle.
final class LiveCaption extends LiveUpdate {
  const LiveCaption({
    required this.fromUser,
    required this.text,
    required this.isFinal,
  });

  final bool fromUser;
  final String text;

  /// The turn is over: this is all of it.
  final bool isFinal;

  @override
  bool operator ==(Object other) =>
      other is LiveCaption &&
      other.fromUser == fromUser &&
      other.text == text &&
      other.isFinal == isFinal;

  @override
  int get hashCode => Object.hash(fromUser, text, isFinal);
}

/// Alesle wants [command] done on the phone; report how it ended under [callId].
final class LiveTaskRun extends LiveUpdate {
  const LiveTaskRun({required this.callId, required this.command});

  final String callId;
  final String command;

  @override
  bool operator ==(Object other) =>
      other is LiveTaskRun &&
      other.callId == callId &&
      other.command == command;

  @override
  int get hashCode => Object.hash(callId, command);
}

/// Change the running task.
final class LiveTaskAmend extends LiveUpdate {
  const LiveTaskAmend(this.text);

  final String text;

  @override
  bool operator ==(Object other) =>
      other is LiveTaskAmend && other.text == text;

  @override
  int get hashCode => text.hashCode;
}

/// Stop the running task.
final class LiveTaskStop extends LiveUpdate {
  const LiveTaskStop();

  @override
  bool operator ==(Object other) => other is LiveTaskStop;

  @override
  int get hashCode => 0;
}

/// The conversation is over: the user said goodbye, or ended it outside the app.
final class LiveEnded extends LiveUpdate {
  const LiveEnded();

  @override
  bool operator ==(Object other) => other is LiveEnded;

  @override
  int get hashCode => 1;
}

/// How loud the conversation is now, 0..1 (the user's voice, or Alesle's
/// while it speaks), for the orb.
final class LiveLevel extends LiveUpdate {
  const LiveLevel(this.level);

  final double level;

  @override
  bool operator ==(Object other) => other is LiveLevel && other.level == level;

  @override
  int get hashCode => level.hashCode;
}
