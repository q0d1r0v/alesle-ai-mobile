import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/agent_debug_data_providers.dart';
import '../domain/agent_console.dart';

/// Developer console for the native agent runtime, reachable in debug builds
/// only (long-press the home title). Not user-facing, so its strings are
/// plain English rather than ARB.
///
/// Snapshots and screen actions act on whatever app is in front, so both can
/// run after a delay: press, switch to the app under test, come back.
class AgentDebugScreen extends ConsumerStatefulWidget {
  const AgentDebugScreen({super.key});

  @override
  ConsumerState<AgentDebugScreen> createState() => _AgentDebugScreenState();
}

class _AgentDebugScreenState extends ConsumerState<AgentDebugScreen> {
  static const List<int> _delays = <int>[0, 3, 5];

  /// One-tap actions; the text field takes any other ActionJson.
  static const Map<String, String> _presets = <String, String>{
    'back': '{"type":"back"}',
    'home': '{"type":"home"}',
    'recents': '{"type":"recents"}',
    'scroll ↓': '{"type":"scroll","direction":"down"}',
    'scroll ↑': '{"type":"scroll","direction":"up"}',
  };

  final TextEditingController _action = TextEditingController(
    text: '{"type":"tap","nodeId":0}',
  );
  final TextEditingController _command = TextEditingController();
  final List<TaskUpdate> _events = <TaskUpdate>[];
  late final StreamSubscription<TaskUpdate> _subscription;

  int _delay = 3;
  bool _busy = false;
  String? _snapshotJson;
  String? _result;

  AgentConsoleRepository get _console =>
      ref.read(agentConsoleRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _subscription = _console.events.listen(
      (TaskUpdate event) => setState(() => _events.insert(0, event)),
    );
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    _action.dispose();
    _command.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() body) async {
    setState(() => _busy = true);
    try {
      if (_delay > 0) await Future<void>.delayed(Duration(seconds: _delay));
      await body();
    } on Exception catch (error) {
      setState(() => _result = 'failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _snapshot() => _run(() async {
    final String json = await _console.snapshot();
    setState(() => _snapshotJson = json);
  });

  Future<void> _execute(String actionJson) => _run(() async {
    final String result = await _console.execute(actionJson);
    setState(() => _result = result);
  });

  Future<void> _startTask() async {
    try {
      final TaskStart start = await _console.startTask(
        TaskCommand(
          text: _command.text,
          locale: Localizations.localeOf(context).toLanguageTag(),
          confirmSensitiveActions: true,
        ),
      );
      setState(
        () => _result = start.started
            ? 'task started'
            : 'refused: ${start.reason}',
      );
    } on Exception catch (error) {
      setState(() => _result = 'failed: $error');
    }
  }

  Future<void> _stopTask() async {
    try {
      await _console.stopTask();
    } on Exception catch (error) {
      setState(() => _result = 'failed: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme text = Theme.of(context).textTheme;
    const TextStyle mono = TextStyle(fontFamily: 'monospace', fontSize: 12);
    return Scaffold(
      appBar: AppBar(title: const Text('Agent console')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Row(
            children: <Widget>[
              Text('Delay', style: text.labelLarge),
              const SizedBox(width: 12),
              for (final int seconds in _delays)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    key: Key('delay-$seconds'),
                    label: Text('${seconds}s'),
                    selected: _delay == seconds,
                    onSelected: (_) => setState(() => _delay = seconds),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('snapshot-button'),
            onPressed: _busy ? null : _snapshot,
            icon: const Icon(Icons.center_focus_strong_outlined),
            label: const Text('Snapshot'),
          ),
          if (_busy) const LinearProgressIndicator(),
          if (_snapshotJson case final String json) _SnapshotView(json: json),
          const Divider(height: 32),
          Text('Action', style: text.titleMedium),
          const SizedBox(height: 8),
          TextField(
            key: const Key('action-field'),
            controller: _action,
            style: mono,
            maxLines: 3,
            minLines: 1,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              FilledButton(
                key: const Key('run-button'),
                onPressed: _busy ? null : () => _execute(_action.text),
                child: const Text('Run'),
              ),
              for (final MapEntry<String, String> preset in _presets.entries)
                OutlinedButton(
                  onPressed: _busy ? null : () => _execute(preset.value),
                  child: Text(preset.key),
                ),
            ],
          ),
          if (_result case final String result) ...<Widget>[
            const SizedBox(height: 8),
            SelectableText(result, key: const Key('result'), style: mono),
          ],
          const Divider(height: 32),
          Text('Task', style: text.titleMedium),
          const SizedBox(height: 8),
          TextField(
            key: const Key('command-field'),
            controller: _command,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Command',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              FilledButton(
                key: const Key('start-button'),
                onPressed: _startTask,
                child: const Text('Start'),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                key: const Key('stop-button'),
                onPressed: _stopTask,
                child: const Text('Stop'),
              ),
            ],
          ),
          for (final TaskUpdate event in _events)
            Text(event.toString(), style: mono),
        ],
      ),
    );
  }
}

/// One line per node, so ids are easy to pick for the next action.
class _SnapshotView extends StatelessWidget {
  const _SnapshotView({required this.json});

  final String json;

  @override
  Widget build(BuildContext context) {
    const TextStyle mono = TextStyle(fontFamily: 'monospace', fontSize: 12);
    final Object? decoded = jsonDecode(json);
    if (decoded is! Map<String, Object?> ||
        decoded['snapshot'] is! Map<String, Object?>) {
      return SelectableText(
        json,
        key: const Key('snapshot-error'),
        style: mono,
      );
    }
    final Map<String, Object?> snapshot =
        decoded['snapshot']! as Map<String, Object?>;
    final List<Object?> nodes =
        snapshot['nodes'] as List<Object?>? ?? <Object?>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 8),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '${snapshot['package']} · ${nodes.length} nodes · '
                '${decoded['captureMs']} ms',
                key: const Key('snapshot-summary'),
              ),
            ),
            IconButton(
              tooltip: 'Copy JSON',
              icon: const Icon(Icons.copy),
              onPressed: () =>
                  unawaited(Clipboard.setData(ClipboardData(text: json))),
            ),
          ],
        ),
        for (final Object? node in nodes)
          if (node is Map<String, Object?>)
            SelectableText(_line(node), style: mono),
      ],
    );
  }

  static String _line(Map<String, Object?> node) {
    final String label = <Object?>[
      node['text'],
      node['desc'],
      node['viewId'],
    ].whereType<String>().join(' | ');
    final String flags = <String>[
      if (node['clickable'] == true) 'C',
      if (node['editable'] == true) 'E',
      if (node['scrollable'] == true) 'S',
    ].join();
    return '${node['id']} ${node['role']} $flags $label';
  }
}
