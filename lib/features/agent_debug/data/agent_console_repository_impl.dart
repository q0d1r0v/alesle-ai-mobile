import 'dart:async';

import 'package:flutter/services.dart';

import '../../../core/errors/failure.dart';
import '../../../core/platform/generated/agent_api.g.dart';
import '../domain/agent_console.dart';

final class AgentConsoleRepositoryImpl
    implements AgentConsoleRepository, AgentEventsApi {
  AgentConsoleRepositoryImpl({
    AgentHostApi? api,
    void Function(AgentEventsApi?)? registerEvents,
  }) : _api = api ?? AgentHostApi(),
       _registerEvents = registerEvents ?? AgentEventsApi.setUp {
    _events = StreamController<TaskEvent>.broadcast(
      onListen: () => _registerEvents(this),
      onCancel: () => _registerEvents(null),
    );
  }

  final AgentHostApi _api;
  final void Function(AgentEventsApi?) _registerEvents;
  late final StreamController<TaskEvent> _events;

  @override
  Stream<TaskEvent> get events => _events.stream;

  @override
  void onStepEvent(StepEvent event) {
    _events.add(TaskEvent(_kinds[event.kind]!, event.text));
  }

  @override
  Future<String> snapshot() => _guard(_api.debugSnapshot);

  @override
  Future<String> execute(String actionJson) =>
      _guard(() => _api.debugExecute(actionJson));

  @override
  Future<TaskStart> startTask(String command) => _guard(() async {
    final StartTaskResult result = await _api.startTask(command);
    return TaskStart(started: result.started, reason: result.reason);
  });

  @override
  Future<void> stopTask() => _guard(_api.stopTask);

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PlatformException catch (error) {
      throw UnexpectedFailure(error);
    }
  }

  static const Map<StepEventKind, TaskEventKind> _kinds =
      <StepEventKind, TaskEventKind>{
        StepEventKind.started: TaskEventKind.started,
        StepEventKind.step: TaskEventKind.step,
        StepEventKind.finished: TaskEventKind.finished,
        StepEventKind.stopped: TaskEventKind.stopped,
      };
}
