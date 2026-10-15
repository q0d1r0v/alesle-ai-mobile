import '../../../core/agent/agent_task.dart';
import 'agent_status.dart';
import 'server_health.dart';

/// Backend reachability. Throws a `Failure` from core/errors on error.
abstract interface class HealthRepository {
  Future<ServerHealth> readiness();
}

/// The on-device agent runtime (Kotlin, via Pigeon).
abstract interface class AgentRepository {
  Future<AgentStatus> status();

  Future<void> openAccessibilitySettings();
}

/// Runs the user's commands on the agent (Kotlin loop + API). Throws a
/// `Failure` from core/errors when the platform call itself fails.
abstract interface class AssistantRepository {
  /// Refused with `not_signed_in` when there is no token yet.
  Future<TaskStart> start(TaskCommand command);

  Future<void> stop();

  /// Updates of the running task, while anyone listens.
  Stream<TaskUpdate> get updates;
}

/// What the speech service heard.
final class Transcript {
  const Transcript({
    required this.text,
    required this.language,
    required this.confidence,
  });

  /// "" when nothing intelligible was said.
  final String text;

  /// en, uz, ru or other.
  final String language;
  final double confidence;
}

/// Push-to-talk (SOW 04 §4.1). Throws a `Failure` from core/errors.
abstract interface class VoiceRepository {
  /// True when the microphone may be used; asks once, and opens app info
  /// when the user has said "don't ask again".
  Future<bool> ensureMicrophone();

  Future<void> startListening();

  /// Stops and transcribes; null when the recording was too short.
  Future<Transcript?> finishListening({String? language});

  Future<void> cancelListening();

  /// Reads [text] aloud.
  Future<void> speak(String text);
}
