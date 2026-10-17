import 'package:alesle_ai/features/home/domain/live.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('live updates are equal by value', () {
    final List<(LiveUpdate, LiveUpdate, LiveUpdate)> cases =
        <(LiveUpdate, LiveUpdate, LiveUpdate)>[
          (
            const LiveStageChanged(LiveStage.hearing),
            const LiveStageChanged(LiveStage.hearing),
            const LiveStageChanged(LiveStage.speaking),
          ),
          (
            const LiveCaption(fromUser: true, text: 'Salom', isFinal: false),
            const LiveCaption(fromUser: true, text: 'Salom', isFinal: false),
            const LiveCaption(fromUser: true, text: 'Salom', isFinal: true),
          ),
          (
            const LiveTaskRun(callId: 'c1', command: 'Soatni och'),
            const LiveTaskRun(callId: 'c1', command: 'Soatni och'),
            const LiveTaskRun(callId: 'c2', command: 'Soatni och'),
          ),
          (
            const LiveTaskAmend('ham'),
            const LiveTaskAmend('ham'),
            const LiveTaskAmend('yana'),
          ),
          (
            const LiveTaskStop(),
            const LiveTaskStop(),
            const LiveTaskAmend('stop'),
          ),
          (const LiveEnded(), const LiveEnded(), const LiveTaskStop()),
        ];
    for (final (LiveUpdate a, LiveUpdate same, LiveUpdate other) in cases) {
      expect(a, same);
      expect(a.hashCode, same.hashCode);
      expect(a, isNot(other));
    }
  });
}
