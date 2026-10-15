import 'dart:async';

import '../agent/agent_task.dart';
import 'generated/agent_api.g.dart';

/// The one receiver of native task events. Pigeon allows a single handler
/// per channel, so every feature listens here instead of registering its own
/// (a second registration would silently steal the first one's events).
final class AgentEventsBridge implements AgentEventsApi {
  AgentEventsBridge({void Function(AgentEventsApi?)? register})
    : _register = register ?? AgentEventsApi.setUp {
    _updates = StreamController<TaskUpdate>.broadcast(
      onListen: () => _register(this),
      onCancel: () => _register(null),
    );
  }

  final void Function(AgentEventsApi?) _register;
  late final StreamController<TaskUpdate> _updates;

  /// Native events while anyone listens.
  Stream<TaskUpdate> get updates => _updates.stream;

  @override
  void onStepEvent(StepEvent event) {
    _updates.add(
      TaskUpdate(
        switch (event.kind) {
          StepEventKind.started => TaskUpdateKind.started,
          StepEventKind.step => TaskUpdateKind.step,
          StepEventKind.finished => TaskUpdateKind.finished,
        },
        text: event.text,
        status: event.status,
        reason: event.reason,
      ),
    );
  }
}
