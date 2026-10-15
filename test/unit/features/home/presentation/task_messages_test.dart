import 'package:alesle_ai/app/l10n/app_localizations.dart';
import 'package:alesle_ai/app/l10n/app_localizations_uz.dart';
import 'package:alesle_ai/core/agent/agent_task.dart';
import 'package:alesle_ai/features/home/presentation/task_messages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final AppLocalizations l10n = AppLocalizationsUz();

  test('titles each outcome', () {
    expect(taskTitle(l10n, TaskOutcome.done), 'Bajarildi');
    expect(taskTitle(l10n, TaskOutcome.stopped), 'To‘xtatildi');
    for (final TaskOutcome outcome in <TaskOutcome>[
      TaskOutcome.failed,
      TaskOutcome.cannot,
      TaskOutcome.interrupted,
    ]) {
      expect(taskTitle(l10n, outcome), 'Bajarib bo‘lmadi');
    }
  });

  test('explains failures by reason, preferring the agent reply', () {
    String? explain(String? reason, {String? reply}) => taskExplanation(
      l10n,
      outcome: TaskOutcome.failed,
      reason: reason,
      reply: reply,
    );
    expect(explain('stuck'), l10n.reasonStuck);
    expect(explain('timeout'), l10n.reasonTimeout);
    expect(explain('connection_lost'), l10n.reasonConnection);
    expect(explain('server_unreachable'), l10n.reasonServer);
    expect(explain('ai_unavailable'), l10n.reasonAi);
    expect(explain('step_limit'), l10n.reasonSteps);
    expect(explain('accessibility_off'), l10n.accessibilityDisabled);
    expect(explain('not_signed_in'), l10n.reasonNotSignedIn);
    expect(explain('already_running'), l10n.reasonAlreadyRunning);
    expect(explain('something_new'), l10n.reasonGeneric);
    expect(explain(null), l10n.reasonGeneric);
    expect(explain('stuck', reply: 'Kontakt topilmadi'), 'Kontakt topilmadi');
    expect(explain('stuck', reply: '  '), l10n.reasonStuck);
  });

  test('says nothing more for done or stopped tasks', () {
    expect(
      taskExplanation(l10n, outcome: TaskOutcome.done, reason: 'x'),
      isNull,
    );
    expect(
      taskExplanation(l10n, outcome: TaskOutcome.stopped, reply: 'x'),
      isNull,
    );
  });

  test('greets by the hour', () {
    expect(greeting(l10n, DateTime(2026, 1, 1, 4)), 'Xayrli kech');
    expect(greeting(l10n, DateTime(2026, 1, 1, 5)), 'Xayrli tong');
    expect(greeting(l10n, DateTime(2026, 1, 1, 11, 59)), 'Xayrli tong');
    expect(greeting(l10n, DateTime(2026, 1, 1, 12)), 'Xayrli kun');
    expect(greeting(l10n, DateTime(2026, 1, 1, 18)), 'Xayrli kech');
  });
}
