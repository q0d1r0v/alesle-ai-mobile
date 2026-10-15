import 'package:alesle_ai/features/agent_debug/domain/agent_console.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('task events compare by every field', () {
    const TaskEvent done = TaskEvent(
      TaskEventKind.finished,
      text: 'Sent',
      status: 'done',
    );
    expect(
      done,
      const TaskEvent(TaskEventKind.finished, text: 'Sent', status: 'done'),
    );
    expect(
      done.hashCode,
      const TaskEvent(
        TaskEventKind.finished,
        text: 'Sent',
        status: 'done',
      ).hashCode,
    );
    expect(done, isNot(const TaskEvent(TaskEventKind.finished, text: 'Sent')));
    expect(
      done,
      isNot(
        const TaskEvent(
          TaskEventKind.finished,
          text: 'Sent',
          status: 'done',
          reason: 'x',
        ),
      ),
    );
    expect(
      const TaskEvent(TaskEventKind.step, text: 'a'),
      isNot(const TaskEvent(TaskEventKind.started, text: 'a')),
    );
  });

  test('task events read well in a log', () {
    expect(const TaskEvent(TaskEventKind.started).toString(), 'started');
    expect(
      const TaskEvent(TaskEventKind.step, text: 'Telegram').toString(),
      'step: Telegram',
    );
    expect(
      const TaskEvent(
        TaskEventKind.finished,
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

    const TaskStart refused = TaskStart(
      started: false,
      reason: 'accessibility_off',
    );
    expect(refused.started, isFalse);
    expect(refused.reason, 'accessibility_off');
  });
}
