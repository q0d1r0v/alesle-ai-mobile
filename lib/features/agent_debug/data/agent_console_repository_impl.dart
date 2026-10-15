import 'dart:async';

import 'package:flutter/services.dart';

import '../../../core/config/app_config.dart';
import '../../../core/errors/failure.dart';
import '../../../core/platform/generated/agent_api.g.dart';
import '../domain/agent_console.dart';

final class AgentConsoleRepositoryImpl
    implements AgentConsoleRepository, AgentEventsApi {
  AgentConsoleRepositoryImpl({
    required this._config,
    AgentHostApi? api,
    void Function(AgentEventsApi?)? registerEvents,
  }) : _api = api ?? AgentHostApi(),
       _registerEvents = registerEvents ?? AgentEventsApi.setUp {
    _events = StreamController<TaskEvent>.broadcast(
      onListen: () => _registerEvents(this),
      onCancel: () => _registerEvents(null),
    );
  }

  final AppConfig _config;
  final AgentHostApi _api;
  final void Function(AgentEventsApi?) _registerEvents;
  late final StreamController<TaskEvent> _events;

  @override
  Stream<TaskEvent> get events => _events.stream;

  @override
  void onStepEvent(StepEvent event) {
    _events.add(
      TaskEvent(
        _kinds[event.kind]!,
        text: event.text,
        status: event.status,
        reason: event.reason,
      ),
    );
  }

  @override
  Future<String> snapshot() => _guard(_api.debugSnapshot);

  @override
  Future<String> execute(String actionJson) =>
      _guard(() => _api.debugExecute(actionJson));

  @override
  Future<TaskStart> startTask(TaskCommand command) async {
    final String? token = _config.devAuthToken;
    if (token == null) {
      return const TaskStart(started: false, reason: 'not_signed_in');
    }
    return _guard(() async {
      final StartTaskResult result = await _api.startTask(
        TaskRequest(
          command: command.text,
          apiBaseUrl: _config.apiBaseUrl,
          accessToken: token,
          locale: command.locale,
          confirmEverySensitiveAction: command.confirmSensitiveActions,
        ),
      );
      return TaskStart(started: result.started, reason: result.reason);
    });
  }

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
      };
}
