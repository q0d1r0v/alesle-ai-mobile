import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/l10n/l10n.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/grouped_card.dart';
import '../data/memory_data_providers.dart';
import '../domain/memory.dart';
import 'memory_messages.dart';

/// Past tasks with what was said (SOW 05 §7); delete one or clear all.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final List<PastTask> _tasks = <PastTask>[];
  DateTime? _next;
  bool _loaded = false;
  bool _busy = false;
  Object? _error;

  MemoryRepository get _repository => ref.read(memoryRepositoryProvider);

  @override
  void initState() {
    super.initState();
    unawaited(_page());
  }

  Future<void> _page() async {
    final MemoryRepository repository = _repository;
    final DateTime? before = _loaded ? _next : null;
    setState(() => _busy = true);
    try {
      final HistoryPage page = await repository.history(before: before);
      if (!mounted) return;
      setState(() {
        _tasks.addAll(page.tasks);
        _next = page.next;
        _loaded = true;
        _error = null;
      });
    } on Object catch (error) {
      if (!mounted) return;
      if (_loaded) {
        _say(memoryFailureMessage(context.l10n, error));
      } else {
        setState(() => _error = error);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _say(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _remove(PastTask task) async {
    final MemoryRepository repository = _repository;
    final AppLocalizations l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await repository.removeTask(task.id);
      if (mounted) setState(() => _tasks.removeWhere((t) => t.id == task.id));
    } on Object catch (error) {
      if (mounted) _say(memoryFailureMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clear() async {
    final AppLocalizations l10n = context.l10n;
    final bool? sure = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialog) => AlertDialog(
        title: Text(l10n.historyClearTitle),
        content: Text(l10n.historyClearBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            key: const Key('history-clear-confirm'),
            style: TextButton.styleFrom(foregroundColor: AlesleColors.danger),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.historyClear),
          ),
        ],
      ),
    );
    if (sure != true) return;
    final MemoryRepository repository = _repository;
    setState(() => _busy = true);
    try {
      await repository.clearHistory();
      if (mounted) {
        setState(() {
          _tasks.clear();
          _next = null;
        });
      }
    } on Object catch (error) {
      if (mounted) _say(memoryFailureMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _when(DateTime at) {
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    final DateTime local = at.toLocal();
    return '${material.formatMediumDate(local)}, '
        '${material.formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: true)}';
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: <Widget>[
          if (_tasks.isNotEmpty)
            IconButton(
              key: const Key('history-clear'),
              tooltip: l10n.historyClear,
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: _busy ? null : _clear,
            ),
        ],
      ),
      body: !_loaded
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          memoryFailureMessage(l10n, _error!),
                          key: const Key('history-error'),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          key: const Key('history-retry'),
                          onPressed: () {
                            setState(() => _error = null);
                            unawaited(_page());
                          },
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
            )
          : _tasks.isEmpty
          ? Center(
              child: Text(
                l10n.historyEmpty,
                key: const Key('history-empty'),
                style: text.bodyLarge,
              ),
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                32 + MediaQuery.paddingOf(context).bottom,
              ),
              children: <Widget>[
                AlesleGroup(
                  children: <Widget>[
                    for (final PastTask task in _tasks)
                      ListTile(
                        key: Key('history-${task.id}'),
                        leading: Icon(
                          _icon(task.status),
                          color: task.status == PastTaskStatus.done
                              ? AlesleColors.violet
                              : AlesleColors.text2,
                        ),
                        title: Text(task.command ?? task.title ?? '—'),
                        subtitle: Text(
                          <String>[
                            _statusLabel(l10n, task.status),
                            if (task.reply case final String reply) reply,
                            _when(task.createdAt),
                          ].join(' · '),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          key: Key('history-delete-${task.id}'),
                          tooltip: l10n.historyDelete,
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: _busy
                              ? null
                              : () => unawaited(_remove(task)),
                        ),
                      ),
                  ],
                ),
                if (_next != null) ...<Widget>[
                  const SizedBox(height: 12),
                  TextButton(
                    key: const Key('history-more'),
                    onPressed: _busy ? null : () => unawaited(_page()),
                    child: Text(l10n.historyLoadMore),
                  ),
                ],
              ],
            ),
    );
  }

  static IconData _icon(PastTaskStatus status) => switch (status) {
    PastTaskStatus.done => Icons.check_circle_outline_rounded,
    PastTaskStatus.stopped => Icons.stop_circle_outlined,
    PastTaskStatus.cannot => Icons.block_rounded,
    PastTaskStatus.failed ||
    PastTaskStatus.interrupted => Icons.error_outline_rounded,
  };

  static String _statusLabel(AppLocalizations l10n, PastTaskStatus status) =>
      switch (status) {
        PastTaskStatus.done => l10n.historyStatusDone,
        PastTaskStatus.failed => l10n.historyStatusFailed,
        PastTaskStatus.cannot => l10n.historyStatusCannot,
        PastTaskStatus.stopped => l10n.historyStatusStopped,
        PastTaskStatus.interrupted => l10n.historyStatusInterrupted,
      };
}
