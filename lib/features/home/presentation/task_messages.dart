import '../../../app/l10n/app_localizations.dart';
import '../../../core/agent/agent_task.dart';

/// The headline of a finished task.
String taskTitle(AppLocalizations l10n, TaskOutcome outcome) =>
    switch (outcome) {
      TaskOutcome.done => l10n.taskDoneTitle,
      TaskOutcome.stopped => l10n.taskStoppedTitle,
      TaskOutcome.failed ||
      TaskOutcome.cannot ||
      TaskOutcome.interrupted => l10n.taskNotDoneTitle,
    };

/// Why a task did not get done, in plain words. The agent's own reply wins
/// when it has one (it says what was missing); codes are never shown.
String? taskExplanation(
  AppLocalizations l10n, {
  required TaskOutcome outcome,
  String? reason,
  String? reply,
}) {
  if (outcome == TaskOutcome.done || outcome == TaskOutcome.stopped) {
    return null;
  }
  if (reply != null && reply.trim().isNotEmpty) return reply;
  return switch (reason) {
    'stuck' => l10n.reasonStuck,
    'timeout' => l10n.reasonTimeout,
    'connection_lost' => l10n.reasonConnection,
    'server_unreachable' => l10n.reasonServer,
    'ai_unavailable' => l10n.reasonAi,
    'step_limit' => l10n.reasonSteps,
    'accessibility_off' => l10n.accessibilityDisabled,
    'not_signed_in' => l10n.reasonNotSignedIn,
    'already_running' => l10n.reasonAlreadyRunning,
    _ => l10n.reasonGeneric,
  };
}

/// "Good morning" until noon, "Good afternoon" until six, then evening.
String greeting(AppLocalizations l10n, DateTime now) => switch (now.hour) {
  >= 5 && < 12 => l10n.greetingMorning,
  >= 12 && < 18 => l10n.greetingDay,
  _ => l10n.greetingEvening,
};
