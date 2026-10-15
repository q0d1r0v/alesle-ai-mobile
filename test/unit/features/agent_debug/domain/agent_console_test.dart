import 'package:alesle_ai/features/agent_debug/domain/agent_console.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('task events compare by kind and text', () {
    expect(
      const TaskEvent(TaskEventKind.started, 'salom'),
      const TaskEvent(TaskEventKind.started, 'salom'),
    );
    expect(
      const TaskEvent(TaskEventKind.started, 'salom').hashCode,
      const TaskEvent(TaskEventKind.started, 'salom').hashCode,
    );
    expect(
      const TaskEvent(TaskEventKind.started, 'salom'),
      isNot(const TaskEvent(TaskEventKind.step, 'salom')),
    );
  });

  test('task events read well in a log', () {
    expect(const TaskEvent(TaskEventKind.stopped).toString(), 'stopped');
    expect(
      const TaskEvent(TaskEventKind.step, 'Telegram').toString(),
      'step: Telegram',
    );
  });

  test('a refused start carries its reason', () {
    const TaskStart refused = TaskStart(
      started: false,
      reason: 'accessibility_off',
    );
    expect(refused.started, isFalse);
    expect(refused.reason, 'accessibility_off');
  });
}
