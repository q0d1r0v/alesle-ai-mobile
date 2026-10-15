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

class StartTaskResult {
  StartTaskResult({required this.started, this.reason});

  final bool started;

  /// Why it did not start, as a snake_case code: `empty_command`,
  /// `already_running`, `accessibility_off`, `background_start_refused`.
  final String? reason;
}

enum StepEventKind {
  /// A task began; `text` is the command.
  started,

  /// The agent moved on; `text` says what it is doing now.
  step,

  /// The task ended on its own; `text` is the final status.
  finished,

  /// The user stopped it (app, notification or overlay).
  stopped,
}

class StepEvent {
  StepEvent({required this.kind, this.text});

  final StepEventKind kind;
  final String? text;
}

@HostApi()
abstract class AgentHostApi {
  AgentStatusMessage getStatus();

  /// Opens the system Accessibility settings screen.
  void openAccessibilitySettings();

  /// Starts a task for a typed or spoken command.
  StartTaskResult startTask(String command);

  /// Stops the running task, if any.
  void stopTask();

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
