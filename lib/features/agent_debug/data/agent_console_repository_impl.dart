import 'package:flutter/services.dart';

import '../../../core/auth/access_token_source.dart';
import '../../../core/config/app_config.dart';
import '../../../core/errors/failure.dart';
import '../../../core/platform/agent_events_bridge.dart';
import '../../../core/platform/generated/agent_api.g.dart';
import '../domain/agent_console.dart';

final class AgentConsoleRepositoryImpl implements AgentConsoleRepository {
  AgentConsoleRepositoryImpl({
    required this._config,
    required this._tokens,
    required this._bridge,
    AgentHostApi? api,
  }) : _api = api ?? AgentHostApi();

  final AppConfig _config;
  final AccessTokenSource _tokens;
  final AgentEventsBridge _bridge;
  final AgentHostApi _api;

  @override
  Stream<TaskUpdate> get events => _bridge.updates;

  @override
  Future<String> snapshot() => _guard(_api.debugSnapshot);

  @override
  Future<String> execute(String actionJson) =>
      _guard(() => _api.debugExecute(actionJson));

  @override
  Future<TaskStart> startTask(TaskCommand command) async {
    final String? token = await _tokens.accessToken(
      margin: const Duration(minutes: 5),
    );
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
}
