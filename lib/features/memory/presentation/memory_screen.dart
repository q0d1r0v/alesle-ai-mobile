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

/// Everything the assistant remembers, with delete and "forget everything"
/// (SOW 05 §7, AC-MEM-3).
class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  List<MemoryEntry>? _entries;
  Object? _error;
  bool _busy = false;

  MemoryRepository get _repository => ref.read(memoryRepositoryProvider);

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final MemoryRepository repository = _repository;
    try {
      final List<MemoryEntry> entries = await repository.memories();
      if (mounted) {
        setState(() {
          _entries = entries;
          _error = null;
        });
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  Future<void> _act(Future<void> Function() action, String done) async {
    if (_busy) return;
    setState(() => _busy = true);
    final AppLocalizations l10n = context.l10n;
    try {
      await action();
      if (mounted) _say(done);
    } on Object catch (error) {
      if (mounted) _say(memoryFailureMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _say(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _forget(MemoryEntry entry) {
    final MemoryRepository repository = _repository;
    return _act(() async {
      await repository.forget(entry.id);
      if (mounted) {
        setState(
          () => _entries = <MemoryEntry>[
            for (final MemoryEntry e in _entries ?? const <MemoryEntry>[])
              if (e.id != entry.id) e,
          ],
        );
      }
    }, context.l10n.memoryForgotten);
  }

  Future<void> _forgetAll() async {
    final AppLocalizations l10n = context.l10n;
    final bool? sure = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialog) => AlertDialog(
        title: Text(l10n.memoryForgetAllTitle),
        content: Text(l10n.memoryForgetAllBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            key: const Key('memory-forget-all-confirm'),
            style: TextButton.styleFrom(foregroundColor: AlesleColors.danger),
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l10n.memoryForgetAll),
          ),
        ],
      ),
    );
    if (sure != true) return;
    final MemoryRepository repository = _repository;
    await _act(() async {
      await repository.forgetAll();
      if (mounted) setState(() => _entries = const <MemoryEntry>[]);
    }, l10n.memoryForgotten);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme text = Theme.of(context).textTheme;
    final List<MemoryEntry>? entries = _entries;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.memoryTitle)),
      body: entries == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : _Retry(
                      message: memoryFailureMessage(l10n, _error!),
                      onRetry: () {
                        setState(() => _error = null);
                        unawaited(_load());
                      },
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
                Text(
                  l10n.memoryBody,
                  style: text.bodyMedium?.copyWith(color: AlesleColors.text2),
                ),
                const SizedBox(height: 16),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Text(
                      l10n.memoryEmpty,
                      key: const Key('memory-empty'),
                      textAlign: TextAlign.center,
                      style: text.bodyLarge,
                    ),
                  )
                else ...<Widget>[
                  AlesleGroup(
                    children: <Widget>[
                      for (final MemoryEntry entry in entries)
                        ListTile(
                          key: Key('memory-${entry.id}'),
                          leading: Icon(_icon(entry.kind)),
                          title: Text(entry.content),
                          subtitle: Text(_kindLabel(l10n, entry.kind)),
                          trailing: IconButton(
                            key: Key('memory-forget-${entry.id}'),
                            tooltip: l10n.memoryForget,
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: _busy
                                ? null
                                : () => unawaited(_forget(entry)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    key: const Key('memory-forget-all'),
                    style: TextButton.styleFrom(
                      foregroundColor: AlesleColors.danger,
                    ),
                    onPressed: _busy ? null : _forgetAll,
                    child: Text(l10n.memoryForgetAll),
                  ),
                ],
              ],
            ),
    );
  }

  static IconData _icon(MemoryKind kind) => switch (kind) {
    MemoryKind.contactAlias => Icons.person_outline_rounded,
    MemoryKind.preference => Icons.tune_rounded,
    MemoryKind.fact => Icons.lightbulb_outline_rounded,
    MemoryKind.episode => Icons.history_rounded,
  };

  static String _kindLabel(AppLocalizations l10n, MemoryKind kind) =>
      switch (kind) {
        MemoryKind.contactAlias => l10n.memoryKindContact,
        MemoryKind.preference => l10n.memoryKindPreference,
        MemoryKind.fact => l10n.memoryKindFact,
        MemoryKind.episode => l10n.memoryKindEpisode,
      };
}

class _Retry extends StatelessWidget {
  const _Retry({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          message,
          key: const Key('memory-error'),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        TextButton(
          key: const Key('memory-retry'),
          onPressed: onRetry,
          child: Text(context.l10n.commonRetry),
        ),
      ],
    );
  }
}
