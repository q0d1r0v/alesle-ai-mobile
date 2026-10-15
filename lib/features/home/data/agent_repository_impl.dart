import 'package:flutter/services.dart';

import '../../../core/errors/failure.dart';
import '../../../core/platform/generated/agent_api.g.dart';
import '../domain/agent_status.dart';
import '../domain/home_repositories.dart';

final class AgentRepositoryImpl implements AgentRepository {
  AgentRepositoryImpl([AgentHostApi? api]) : _api = api ?? AgentHostApi();

  final AgentHostApi _api;

  @override
  Future<AgentStatus> status() async {
    try {
      final AgentStatusMessage message = await _api.getStatus();
      return AgentStatus(
        accessibilityEnabled: message.accessibilityEnabled,
        policy: switch (message.policy) {
          ExecutionPolicyMessage.confirmSensitiveActions =>
            ExecutionPolicy.confirmSensitiveActions,
          ExecutionPolicyMessage.autonomous => ExecutionPolicy.autonomous,
        },
        distribution: message.distribution,
      );
    } on PlatformException catch (error) {
      throw UnexpectedFailure(error);
    }
  }

  @override
  Future<void> openAccessibilitySettings() async {
    try {
      await _api.openAccessibilitySettings();
    } on PlatformException catch (error) {
      throw UnexpectedFailure(error);
    }
  }
}
