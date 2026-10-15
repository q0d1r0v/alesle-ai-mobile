import 'dart:async';

import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/agent_debug/data/agent_debug_data_providers.dart';
import 'package:alesle_ai/features/agent_debug/domain/agent_console.dart';
import 'package:alesle_ai/features/agent_debug/presentation/agent_debug_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/pump_app.dart';

final class _FakeConsole implements AgentConsoleRepository {
  String snapshotJson =
      '{"captureMs":42,"snapshot":{"package":"com.miui.calculator","nodes":['
      '{"id":0,"role":"button","text":"7","desc":null,"viewId":"digit_7","clickable":true,"editable":false,"scrollable":false},'
      '{"id":1,"role":"list","text":null,"desc":null,"viewId":null,"clickable":false,"editable":true,"scrollable":true}]}}';
  String executeResult = '{"status":"ok"}';
  TaskStart start = const TaskStart(started: true);
  Object? error;
  final List<String> executed = <String>[];
  final List<String> commands = <String>[];
  int snapshots = 0;
  int stops = 0;
  final StreamController<TaskUpdate> controller =
      StreamController<TaskUpdate>.broadcast();

  Future<T> _answer<T>(T value) async {
    if (error case final Object e) throw e;
    return value;
  }

  @override
  Future<String> snapshot() {
    snapshots++;
    return _answer(snapshotJson);
  }

  @override
  Future<String> execute(String actionJson) {
    executed.add(actionJson);
    return _answer(executeResult);
  }

  @override
  Future<TaskStart> startTask(TaskCommand command) {
    commands.add(command.text);
    return _answer(start);
  }

  @override
  Future<void> stopTask() {
    stops++;
    return _answer(null);
  }

  @override
  Stream<TaskUpdate> get events => controller.stream;
}

void main() {
  late _FakeConsole console;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpLocalized(
      tester,
      const AgentDebugScreen(),
      overrides: [agentConsoleRepositoryProvider.overrideWithValue(console)],
    );
  }

  setUp(() => console = _FakeConsole());

  testWidgets('takes a snapshot after the chosen delay and lists the nodes', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('snapshot-button')));
    await tester.pump();
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(console.snapshots, 0);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(console.snapshots, 1);
    expect(find.text('com.miui.calculator · 2 nodes · 42 ms'), findsOneWidget);
    expect(find.text('0 button C 7 | digit_7'), findsOneWidget);
    expect(find.text('1 list ES '), findsOneWidget);
  });

  testWidgets('copies the raw snapshot JSON', (WidgetTester tester) async {
    final List<MethodCall> calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        calls.add(call);
        return null;
      },
    );
    await pump(tester);
    await tester.tap(find.byKey(const Key('delay-0')));
    await tester.tap(find.byKey(const Key('snapshot-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Copy JSON'));
    await tester.pump();
    final MethodCall copy = calls.firstWhere(
      (MethodCall c) => c.method == 'Clipboard.setData',
    );
    expect(
      (copy.arguments as Map<Object?, Object?>)['text'],
      console.snapshotJson,
    );
  });

  testWidgets('shows an error answer as it came', (WidgetTester tester) async {
    console.snapshotJson = '{"status":"error","reason":"accessibility_off"}';
    await pump(tester);
    await tester.tap(find.byKey(const Key('delay-0')));
    await tester.tap(find.byKey(const Key('snapshot-button')));
    await tester.pumpAndSettle();
    expect(find.text(console.snapshotJson), findsOneWidget);
  });

  testWidgets('runs typed and preset actions', (WidgetTester tester) async {
    await pump(tester);
    await tester.tap(find.byKey(const Key('delay-0')));
    await tester.enterText(
      find.byKey(const Key('action-field')),
      '{"type":"tap","nodeId":4}',
    );
    await tester.tap(find.byKey(const Key('run-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('back'));
    await tester.pumpAndSettle();

    expect(console.executed, <String>[
      '{"type":"tap","nodeId":4}',
      '{"type":"back"}',
    ]);
    expect(find.text('{"status":"ok"}'), findsOneWidget);
  });

  testWidgets('reports a failed call', (WidgetTester tester) async {
    console.error = UnexpectedFailure(PlatformException(code: 'debug_only'));
    await pump(tester);
    await tester.tap(find.byKey(const Key('delay-0')));
    await tester.tap(find.byKey(const Key('run-button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('failed:'), findsOneWidget);
  });

  testWidgets('starts and stops a task and logs its events', (
    WidgetTester tester,
  ) async {
    await pump(tester);
    await tester.enterText(find.byKey(const Key('command-field')), 'salom');
    await tester.tap(find.byKey(const Key('start-button')));
    await tester.pump();
    expect(console.commands, <String>['salom']);
    expect(find.text('task started'), findsOneWidget);

    console.controller.add(
      const TaskUpdate(TaskUpdateKind.started, text: 'salom'),
    );
    await tester.pump();
    expect(find.text('started: salom'), findsOneWidget);

    await tester.tap(find.byKey(const Key('stop-button')));
    await tester.pump();
    expect(console.stops, 1);

    console.start = const TaskStart(started: false, reason: 'already_running');
    await tester.tap(find.byKey(const Key('start-button')));
    await tester.pump();
    expect(find.text('refused: already_running'), findsOneWidget);
  });

  testWidgets('reports failed task calls', (WidgetTester tester) async {
    console.error = const NetworkFailure();
    await pump(tester);
    await tester.tap(find.byKey(const Key('start-button')));
    await tester.pump();
    expect(find.text('failed: NetworkFailure'), findsOneWidget);

    await tester.tap(find.byKey(const Key('stop-button')));
    await tester.pump();
    expect(console.stops, 1);
    expect(find.text('failed: NetworkFailure'), findsOneWidget);
  });
}
