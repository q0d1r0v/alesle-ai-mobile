// Pigeon contract between Dart and the Kotlin agent runtime.
//
// Regenerate after editing:  dart run pigeon --input pigeons/agent_api.dart
// Generated files are committed; CI fails if they drift from this contract.
//
// The agent loop lives in Kotlin, next to the foreground service, so a task
// keeps running when the Flutter UI is gone (the user is in another app).
// Dart only starts and stops tasks and listens to their events.
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/core/platform/generated/agent_api.g.dart',
    dartPackageName: 'alesle_ai',
    kotlinOut: 'android/app/src/main/kotlin/com/alesle/ai/agent/generated/AgentApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.alesle.ai.agent.generated'),
  ),
)
class AgentStatusMessage {
  AgentStatusMessage({required this.accessibilityEnabled});

  /// Whether the user has switched on Alesle's AccessibilityService.
  final bool accessibilityEnabled;
}

/// Everything the Kotlin loop needs to run one command against the API.
class TaskRequest {
  TaskRequest({
    required this.command,
    required this.apiBaseUrl,
    required this.accessToken,
    required this.locale,
    required this.confirmEverySensitiveAction,
    this.handsFree,
  });

  final String command;

  /// Origin of the API (`AppConfig.apiBaseUrl`); the socket is `/v1/agent/ws` on it.
  final String apiBaseUrl;
  final String accessToken;

  /// BCP-47 tag the agent answers in.
  final String locale;

  /// The user's setting: false = a cancellable countdown instead of a question.
  final bool confirmEverySensitiveAction;

  /// Heard by hands-free listening: words not meant for Alesle are let go
  /// silently (the server ends them as `not_addressed`). Null = false.
  final bool? handsFree;
}

class StartTaskResult {
  StartTaskResult({required this.started, this.reason});

  final bool started;

  /// Why it did not start, as a snake_case code: `empty_command`,
  /// `already_running`, `accessibility_off`, `background_start_refused`,
  /// `bad_server_url`.
  final String? reason;
}

enum StepEventKind {
  /// A task began; `text` is the command.
  started,

  /// The agent moved on; `text` says what it is doing now.
  step,

  /// The task is over: `status` says how, `text` is the agent's reply.
  finished,
}

class StepEvent {
  StepEvent({required this.kind, this.text, this.status, this.reason});

  final StepEventKind kind;
  final String? text;

  /// For `finished`: done, failed, cannot, stopped, interrupted.
  final String? status;

  /// For `finished`: snake_case code when not done (e.g. `connection_lost`).
  final String? reason;
}

@HostApi()
abstract class AgentHostApi {
  AgentStatusMessage getStatus();

  /// Opens the system Accessibility settings screen.
  void openAccessibilitySettings();

  /// Starts a task for a typed or spoken command.
  StartTaskResult startTask(TaskRequest request);

  /// Stops the running task, if any.
  void stopTask();

  /// What the user said while a task runs (hands-free): answers the sheet on
  /// screen or changes the task. False when no task runs.
  bool amendTask(String text);

  /// Debug builds only (fails with `debug_only` otherwise): the current
  /// screen as snapshot JSON, with `captureMs`.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  String debugSnapshot();

  /// Debug builds only: runs one action (ActionJson wire format) on the
  /// screen of the last [debugSnapshot] and returns the result JSON.
  @TaskQueue(type: TaskQueueType.serialBackgroundThread)
  String debugExecute(String actionJson);
}

@FlutterApi()
abstract class AgentEventsApi {
  void onStepEvent(StepEvent event);
}

// ── Device setup and voice (Sprint 4) ───────────────────────────────────────

enum PermissionKind { microphone, contacts, notifications }

enum PermissionState {
  granted,
  denied,

  /// Denied with "don't ask again": only the app's settings page can change it.
  permanentlyDenied,
}

class DeviceSetupMessage {
  DeviceSetupMessage({
    required this.batteryOptimizationIgnored,
    required this.manufacturer,
    required this.sdkInt,
    required this.deviceName,
  });

  /// Android will not stop Alesle to save battery.
  final bool batteryOptimizationIgnored;

  /// `Build.MANUFACTURER`, lower-cased: picks the OEM autostart guide.
  final String manufacturer;
  final int sdkInt;

  /// "Xiaomi 23090RA98G", "Google Pixel 7": names this phone in the device list.
  final String deviceName;
}

@HostApi()
abstract class DeviceHostApi {
  PermissionState permissionState(PermissionKind kind);

  /// Shows the system permission dialog (when Android still allows it).
  @async
  PermissionState requestPermission(PermissionKind kind);

  DeviceSetupMessage setupState();

  /// App info: where "Allow restricted settings" lives (Android 13+, sideloaded).
  void openAppDetails();

  /// The system dialog that exempts Alesle from battery optimisation.
  void requestIgnoreBatteryOptimizations();

  /// The OEM's autostart screen when known (Xiaomi, Oppo, Vivo, Huawei…);
  /// false when there is none and app info was opened instead.
  bool openAutostartSettings();

  /// Starts recording the microphone: AAC, 16 kHz mono, into the app cache.
  void startRecording();

  /// Stops and returns the recording's file path; null when nothing was recorded.
  String? stopRecording();

  void cancelRecording();

  /// Plays an audio file (the agent's spoken reply); stops any earlier one.
  void playAudio(String path);

  void stopAudio();
}

// ── Hands-free listening (SOW 04 §4.3) ──────────────────────────────────────

class ListenStateMessage {
  ListenStateMessage({required this.active, required this.muted});

  /// The microphone service runs.
  final bool active;

  /// The user muted it: nothing is heard until unmuted.
  final bool muted;
}

@HostApi()
abstract class ListenHostApi {
  /// Starts listening; Android allows it only while the app is in front.
  /// The state after (not active when the microphone could not be opened).
  ListenStateMessage startListening();

  void stopListening();

  void setMuted(bool muted);

  ListenStateMessage listenState();
}

@FlutterApi()
abstract class ListenEventsApi {
  /// One utterance as a 16 kHz mono WAV in the app cache; the receiver deletes it.
  void onUtterance(String path);

  void onListenState(ListenStateMessage state);
}

// ── App updates (Sprint 8, SOW 02 §3) ───────────────────────────────────────

class AppVersionMessage {
  AppVersionMessage({
    required this.versionCode,
    required this.versionName,
    required this.certSha256,
  });

  final int versionCode;
  final String versionName;

  /// Lowercase hex SHA-256 of the certificate this build is signed with.
  final String certSha256;
}

enum InstallOutcome {
  /// The system's install confirmation is showing.
  started,

  /// "Install unknown apps" is off for Alesle: its settings page was opened.
  permissionNeeded,

  /// Not Alesle, not newer, or not signed with Alesle's certificate (AC-APP-6).
  rejected,

  failed,
}

@HostApi()
abstract class UpdateHostApi {
  AppVersionMessage appVersion();

  /// Checks that the APK at [path] is a newer com.alesle.ai signed with this
  /// build's certificate, which must also be [expectedCertSha256], then hands
  /// it to PackageInstaller.
  @async
  InstallOutcome install(String path, String expectedCertSha256);
}
