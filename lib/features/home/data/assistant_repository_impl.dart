import 'package:flutter/services.dart';

import '../../../core/agent/agent_task.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/failure.dart';
import '../../../core/platform/agent_events_bridge.dart';
import '../../../core/platform/generated/agent_api.g.dart';
import '../domain/home_repositories.dart';

final class AssistantRepositoryImpl implements AssistantRepository {
  AssistantRepositoryImpl({
    required this._config,
    required this._bridge,
    AgentHostApi? api,
  }) : _api = api ?? AgentHostApi();

  final AppConfig _config;
  final AgentEventsBridge _bridge;
  final AgentHostApi _api;

  @override
  Stream<TaskUpdate> get updates => _bridge.updates;

  @override
  Future<TaskStart> start(TaskCommand command) async {
    // Until accounts exist (Sprint 5) the dev build carries the API's dev token.
    final String? token = _config.devAuthToken;
    if (token == null) {
      return const TaskStart(started: false, reason: 'not_signed_in');
    }
    try {
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
    } on PlatformException catch (error) {
      throw UnexpectedFailure(error);
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _api.stopTask();
    } on PlatformException catch (error) {
      throw UnexpectedFailure(error);
    }
  }
}
