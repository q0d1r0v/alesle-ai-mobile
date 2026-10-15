import 'package:flutter/services.dart';

import '../../../core/errors/failure.dart';
import '../../../core/platform/generated/agent_api.g.dart';
import '../domain/device_setup.dart';

final class DeviceSetupRepositoryImpl implements DeviceSetupRepository {
  DeviceSetupRepositoryImpl({DeviceHostApi? device, AgentHostApi? agent})
    : _device = device ?? DeviceHostApi(),
      _agent = agent ?? AgentHostApi();

  final DeviceHostApi _device;
  final AgentHostApi _agent;

  @override
  Future<PermissionStatus> status(SetupPermission permission) => _guard(
    () async => _status(await _device.permissionState(_kind(permission))),
  );

  @override
  Future<PermissionStatus> request(SetupPermission permission) => _guard(
    () async => _status(await _device.requestPermission(_kind(permission))),
  );

  @override
  Future<DeviceSetup> setup() => _guard(() async {
    final DeviceSetupMessage message = await _device.setupState();
    return DeviceSetup(
      batteryOptimizationIgnored: message.batteryOptimizationIgnored,
      manufacturer: message.manufacturer,
      sdkInt: message.sdkInt,
    );
  });

  @override
  Future<bool> accessibilityEnabled() =>
      _guard(() async => (await _agent.getStatus()).accessibilityEnabled);

  @override
  Future<void> openAccessibilitySettings() =>
      _guard(_agent.openAccessibilitySettings);

  @override
  Future<void> openAppDetails() => _guard(_device.openAppDetails);

  @override
  Future<void> requestBatteryExemption() =>
      _guard(_device.requestIgnoreBatteryOptimizations);

  @override
  Future<bool> openAutostart() => _guard(_device.openAutostartSettings);

  static PermissionKind _kind(SetupPermission permission) =>
      switch (permission) {
        SetupPermission.microphone => PermissionKind.microphone,
        SetupPermission.contacts => PermissionKind.contacts,
        SetupPermission.notifications => PermissionKind.notifications,
      };

  static PermissionStatus _status(PermissionState state) => switch (state) {
    PermissionState.granted => PermissionStatus.granted,
    PermissionState.denied => PermissionStatus.denied,
    PermissionState.permanentlyDenied => PermissionStatus.permanentlyDenied,
  };

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on PlatformException catch (error) {
      throw UnexpectedFailure(error);
    }
  }
}
