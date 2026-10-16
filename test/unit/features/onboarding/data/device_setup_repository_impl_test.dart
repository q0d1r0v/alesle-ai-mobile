import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/platform/generated/agent_api.g.dart';
import 'package:alesle_ai/features/onboarding/data/device_setup_repository_impl.dart';
import 'package:alesle_ai/features/onboarding/domain/device_setup.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDeviceHostApi extends Mock implements DeviceHostApi {}

class _MockAgentHostApi extends Mock implements AgentHostApi {}

void main() {
  late _MockDeviceHostApi device;
  late _MockAgentHostApi agent;
  late DeviceSetupRepositoryImpl repository;

  setUpAll(() => registerFallbackValue(PermissionKind.microphone));

  setUp(() {
    device = _MockDeviceHostApi();
    agent = _MockAgentHostApi();
    repository = DeviceSetupRepositoryImpl(device: device, agent: agent);
  });

  test('maps every permission and answer both ways', () async {
    const Map<SetupPermission, PermissionKind> kinds =
        <SetupPermission, PermissionKind>{
          SetupPermission.microphone: PermissionKind.microphone,
          SetupPermission.contacts: PermissionKind.contacts,
          SetupPermission.notifications: PermissionKind.notifications,
        };
    const Map<PermissionState, PermissionStatus> answers =
        <PermissionState, PermissionStatus>{
          PermissionState.granted: PermissionStatus.granted,
          PermissionState.denied: PermissionStatus.denied,
          PermissionState.permanentlyDenied: PermissionStatus.permanentlyDenied,
        };
    for (final MapEntry<SetupPermission, PermissionKind> kind
        in kinds.entries) {
      for (final MapEntry<PermissionState, PermissionStatus> answer
          in answers.entries) {
        when(() => device.permissionState(kind.value))
            .thenAnswer((_) async => answer.key);
        when(() => device.requestPermission(kind.value))
            .thenAnswer((_) async => answer.key);
        expect(await repository.status(kind.key), answer.value);
        expect(await repository.request(kind.key), answer.value);
      }
    }
  });

  test('reads the device setup and the accessibility switch', () async {
    when(device.setupState).thenAnswer(
      (_) async => DeviceSetupMessage(
        batteryOptimizationIgnored: true,
        manufacturer: 'xiaomi',
        sdkInt: 36,
        deviceName: 'Xiaomi 23090RA98G',
      ),
    );
    when(
      agent.getStatus,
    ).thenAnswer((_) async => AgentStatusMessage(accessibilityEnabled: true));

    final DeviceSetup setup = await repository.setup();
    expect(setup.batteryOptimizationIgnored, isTrue);
    expect(setup.manufacturer, 'xiaomi');
    expect(setup.sdkInt, 36);
    expect(await repository.accessibilityEnabled(), isTrue);
  });

  test('opens the system screens', () async {
    when(agent.openAccessibilitySettings).thenAnswer((_) async {});
    when(device.openAppDetails).thenAnswer((_) async {});
    when(device.requestIgnoreBatteryOptimizations).thenAnswer((_) async {});
    when(device.openAutostartSettings).thenAnswer((_) async => false);

    await repository.openAccessibilitySettings();
    await repository.openAppDetails();
    await repository.requestBatteryExemption();
    expect(await repository.openAutostart(), isFalse);

    verify(agent.openAccessibilitySettings).called(1);
    verify(device.openAppDetails).called(1);
    verify(device.requestIgnoreBatteryOptimizations).called(1);
    verify(device.openAutostartSettings).called(1);
  });

  test('wraps platform errors in UnexpectedFailure', () async {
    when(() => device.permissionState(any()))
        .thenThrow(PlatformException(code: 'channel-error'));
    when(device.setupState).thenThrow(PlatformException(code: 'x'));
    await expectLater(
      repository.status(SetupPermission.microphone),
      throwsA(isA<UnexpectedFailure>()),
    );
    await expectLater(repository.setup(), throwsA(isA<UnexpectedFailure>()));
  });

  test('defaults to the real Pigeon host APIs', () {
    expect(DeviceSetupRepositoryImpl(), isA<DeviceSetupRepositoryImpl>());
  });
}
