import 'dart:async';

import 'package:alesle_ai/core/agent/agent_task.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/core/storage/app_settings.dart';
import 'package:alesle_ai/features/home/domain/agent_status.dart';
import 'package:alesle_ai/features/home/domain/home_repositories.dart';
import 'package:alesle_ai/features/home/domain/server_health.dart';
import 'package:alesle_ai/features/onboarding/domain/device_setup.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hand-written fakes for widget tests: they keep call counts and let a test
/// hold a future open to observe the loading state.
final class FakeHealthRepository implements HealthRepository {
  FakeHealthRepository(this._next);

  Future<ServerHealth> Function() _next;
  int calls = 0;

  set next(Future<ServerHealth> Function() value) => _next = value;

  @override
  Future<ServerHealth> readiness() {
    calls++;
    return _next();
  }
}

final class FakeAgentRepository implements AgentRepository {
  FakeAgentRepository(this._next);

  Future<AgentStatus> Function() _next;
  int statusCalls = 0;
  int openSettingsCalls = 0;

  set next(Future<AgentStatus> Function() value) => _next = value;

  @override
  Future<AgentStatus> status() {
    statusCalls++;
    return _next();
  }

  @override
  Future<void> openAccessibilitySettings() async {
    openSettingsCalls++;
  }
}

const ServerHealth readyHealth = ServerHealth(
  dependencies: <String, String>{
    'database': 'up',
    'pgvector': 'up',
    'redis': 'up',
  },
);

const AgentStatus disabledAgent = AgentStatus(accessibilityEnabled: false);

const AgentStatus enabledAgent = AgentStatus(accessibilityEnabled: true);

/// A future that never completes, for asserting loading states.
Future<T> never<T>() => Completer<T>().future;

/// Records commands and lets a test push task updates.
final class FakeAssistantRepository implements AssistantRepository {
  final StreamController<TaskUpdate> updatesController =
      StreamController<TaskUpdate>.broadcast();
  final List<TaskCommand> commands = <TaskCommand>[];
  TaskStart nextStart = const TaskStart(started: true);
  Failure? failure;
  int stops = 0;

  @override
  Stream<TaskUpdate> get updates => updatesController.stream;

  @override
  Future<TaskStart> start(TaskCommand command) async {
    commands.add(command);
    if (failure case final Failure value) throw value;
    return nextStart;
  }

  @override
  Future<void> stop() async {
    stops++;
    if (failure case final Failure value) throw value;
  }

  void push(TaskUpdate update) => updatesController.add(update);
}

/// Scripted push-to-talk: the microphone answer, what was heard, failures.
final class FakeVoiceRepository implements VoiceRepository {
  bool microphone = true;
  Transcript? heard = const Transcript(
    text: 'Onamga qo‘ng‘iroq qil',
    language: 'uz',
    confidence: 0.9,
  );
  Failure? failure;
  int starts = 0;
  int cancels = 0;
  final List<String?> languages = <String?>[];
  final List<String> spoken = <String>[];

  @override
  Future<bool> ensureMicrophone() async {
    if (failure case final Failure value) throw value;
    return microphone;
  }

  @override
  Future<void> startListening() async => starts++;

  @override
  Future<Transcript?> finishListening({String? language}) async {
    languages.add(language);
    if (failure case final Failure value) throw value;
    return heard;
  }

  @override
  Future<void> cancelListening() async => cancels++;

  @override
  Future<void> speak(String text) async {
    if (failure case final Failure value) throw value;
    spoken.add(text);
  }
}

/// A settings store over mocked SharedPreferences.
Future<AppSettingsStore> testSettingsStore({
  bool onboardingDone = true,
  String? language,
  bool voiceReplies = true,
  bool confirmSensitiveActions = true,
}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{
    'onboarding_done': onboardingDone,
    'language': ?language,
    'voice_replies': voiceReplies,
    'confirm_sensitive_actions': confirmSensitiveActions,
  });
  return AppSettingsStore.load();
}

/// A phone whose permissions, switches and screens a test controls.
final class FakeDeviceSetup implements DeviceSetupRepository {
  final Map<SetupPermission, PermissionStatus> statuses =
      <SetupPermission, PermissionStatus>{};

  /// What the system dialog answers.
  PermissionStatus answer = PermissionStatus.granted;
  bool accessibility = false;
  DeviceSetup device = const DeviceSetup(
    batteryOptimizationIgnored: false,
    manufacturer: 'xiaomi',
    sdkInt: 34,
  );
  Failure? failure;
  final List<String> calls = <String>[];

  void _check() {
    if (failure case final Failure value) throw value;
  }

  @override
  Future<PermissionStatus> status(SetupPermission permission) async {
    _check();
    return statuses[permission] ?? PermissionStatus.denied;
  }

  @override
  Future<PermissionStatus> request(SetupPermission permission) async {
    calls.add('request:${permission.name}');
    statuses[permission] = answer;
    return answer;
  }

  @override
  Future<DeviceSetup> setup() async {
    _check();
    return device;
  }

  @override
  Future<bool> accessibilityEnabled() async {
    _check();
    return accessibility;
  }

  @override
  Future<void> openAccessibilitySettings() async => calls.add('accessibility');

  @override
  Future<void> openAppDetails() async => calls.add('appDetails');

  @override
  Future<void> requestBatteryExemption() async => calls.add('battery');

  @override
  Future<bool> openAutostart() async {
    calls.add('autostart');
    return true;
  }
}
