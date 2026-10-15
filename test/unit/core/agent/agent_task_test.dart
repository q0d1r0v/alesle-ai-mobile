import 'package:alesle_ai/core/agent/agent_task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('updates compare by every field', () {
    const TaskUpdate done = TaskUpdate(
      TaskUpdateKind.finished,
      text: 'Sent',
      status: 'done',
    );
    expect(
      done,
      const TaskUpdate(TaskUpdateKind.finished, text: 'Sent', status: 'done'),
    );
    expect(
      done.hashCode,
      const TaskUpdate(
        TaskUpdateKind.finished,
        text: 'Sent',
        status: 'done',
      ).hashCode,
    );
    expect(
      done,
      isNot(const TaskUpdate(TaskUpdateKind.finished, text: 'Sent')),
    );
    expect(
      done,
      isNot(
        const TaskUpdate(
          TaskUpdateKind.finished,
          text: 'Sent',
          status: 'done',
          reason: 'x',
        ),
      ),
    );
    expect(
      const TaskUpdate(TaskUpdateKind.step, text: 'a'),
      isNot(const TaskUpdate(TaskUpdateKind.started, text: 'a')),
    );
  });

  test('reads its outcome; unknown statuses count as failed', () {
    expect(const TaskUpdate(TaskUpdateKind.step).outcome, isNull);
    expect(
      const TaskUpdate(TaskUpdateKind.finished, status: 'cannot').outcome,
      TaskOutcome.cannot,
    );
    expect(
      const TaskUpdate(TaskUpdateKind.finished, status: 'weird').outcome,
      TaskOutcome.failed,
    );
    expect(
      const TaskUpdate(TaskUpdateKind.finished).outcome,
      TaskOutcome.failed,
    );
  });

  test('reads well in a log', () {
    expect(const TaskUpdate(TaskUpdateKind.started).toString(), 'started');
    expect(
      const TaskUpdate(TaskUpdateKind.step, text: 'Telegram').toString(),
      'step: Telegram',
    );
    expect(
      const TaskUpdate(
        TaskUpdateKind.finished,
        status: 'failed',
        reason: 'stuck',
      ).toString(),
      'finished failed stuck',
    );
  });

  test('commands and refusals carry their fields', () {
    const TaskCommand command = TaskCommand(
      text: 'salom',
      locale: 'uz',
      confirmSensitiveActions: false,
    );
    expect(command.text, 'salom');
    expect(command.locale, 'uz');
    expect(command.confirmSensitiveActions, isFalse);
    const TaskStart refused = TaskStart(started: false, reason: 'x');
    expect(refused.started, isFalse);
    expect(refused.reason, 'x');
  });
}
