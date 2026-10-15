import 'dart:async';

import 'package:alesle_ai/app/bootstrap/core_providers.dart';
import 'package:alesle_ai/core/agent/agent_task.dart';
import 'package:alesle_ai/core/platform/agent_events_bridge.dart';
import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('registers with Pigeon only while someone listens', () async {
    final List<AgentEventsApi?> registrations = <AgentEventsApi?>[];
    final AgentEventsBridge bridge = AgentEventsBridge(
      register: registrations.add,
    );
    expect(registrations, isEmpty);

    final List<TaskUpdate> first = <TaskUpdate>[];
    final List<TaskUpdate> second = <TaskUpdate>[];
    final StreamSubscription<TaskUpdate> a = bridge.updates.listen(first.add);
    final StreamSubscription<TaskUpdate> b = bridge.updates.listen(second.add);
    expect(registrations, <AgentEventsApi?>[bridge]);

    bridge
      ..onStepEvent(StepEvent(kind: StepEventKind.started, text: 'salom'))
      ..onStepEvent(StepEvent(kind: StepEventKind.step, text: 'Telegram'))
      ..onStepEvent(
        StepEvent(
          kind: StepEventKind.finished,
          text: 'Done',
          status: 'done',
          reason: null,
        ),
      );
    await Future<void>.delayed(Duration.zero);

    const List<TaskUpdate> expected = <TaskUpdate>[
      TaskUpdate(TaskUpdateKind.started, text: 'salom'),
      TaskUpdate(TaskUpdateKind.step, text: 'Telegram'),
      TaskUpdate(TaskUpdateKind.finished, text: 'Done', status: 'done'),
    ];
    expect(first, expected);
    expect(second, expected);

    await a.cancel();
    expect(registrations, <AgentEventsApi?>[bridge]);
    await b.cancel();
    expect(registrations, <AgentEventsApi?>[bridge, null]);
  });

  test('is one per app', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    expect(
      container.read(agentEventsBridgeProvider),
      same(container.read(agentEventsBridgeProvider)),
    );
  });
}
