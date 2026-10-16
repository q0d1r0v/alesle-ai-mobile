import '../../../core/api/generated/clients/history_api.dart';
import '../../../core/api/generated/clients/memory_api.dart';
import '../../../core/api/generated/models/history_item_dto.dart';
import '../../../core/api/generated/models/history_page_dto.dart';
import '../../../core/api/generated/models/memory_item_dto.dart';
import '../../../core/api/generated/models/memory_kind.dart';
import '../../../core/api/generated/models/task_status.dart';
import '../../../core/network/dio_error_mapper.dart';
import '../domain/memory.dart' as domain;

final class MemoryRepositoryImpl implements domain.MemoryRepository {
  MemoryRepositoryImpl({required this._memory, required this._history});

  final MemoryApi _memory;
  final HistoryApi _history;

  static const int pageSize = 20;

  @override
  Future<List<domain.MemoryEntry>> memories() => _call(() async {
    final List<MemoryItemDto> items = await _memory.memoryList();
    return <domain.MemoryEntry>[
      for (final MemoryItemDto item in items)
        domain.MemoryEntry(
          id: item.id,
          kind: _kind(item.kind),
          content: item.content,
          updatedAt: item.updatedAt,
        ),
    ];
  });

  @override
  Future<void> forget(String id) => _call(() => _memory.memoryRemove(id: id));

  @override
  Future<void> forgetAll() => _call(_memory.memoryForgetAll);

  @override
  Future<domain.HistoryPage> history({DateTime? before}) => _call(() async {
    final HistoryPageDto page = await _history.historyList(
      before: before,
      limit: pageSize,
    );
    return domain.HistoryPage(
      tasks: <domain.PastTask>[
        for (final HistoryItemDto item in page.items)
          domain.PastTask(
            id: item.id,
            title: item.title,
            status: _status(item.status),
            command: item.command,
            reply: item.reply,
            createdAt: item.createdAt,
          ),
      ],
      next: page.next,
    );
  });

  @override
  Future<void> removeTask(String id) =>
      _call(() => _history.historyRemove(id: id));

  @override
  Future<void> clearHistory() => _call(_history.historyClear);

  static domain.MemoryKind _kind(MemoryKind kind) => switch (kind) {
    MemoryKind.preference => domain.MemoryKind.preference,
    MemoryKind.contactAlias => domain.MemoryKind.contactAlias,
    MemoryKind.episode => domain.MemoryKind.episode,
    MemoryKind.fact || MemoryKind.$unknown => domain.MemoryKind.fact,
  };

  static domain.PastTaskStatus _status(TaskStatus status) => switch (status) {
    TaskStatus.done => domain.PastTaskStatus.done,
    TaskStatus.cannot => domain.PastTaskStatus.cannot,
    TaskStatus.stopped => domain.PastTaskStatus.stopped,
    TaskStatus.interrupted => domain.PastTaskStatus.interrupted,
    TaskStatus.failed || TaskStatus.$unknown => domain.PastTaskStatus.failed,
  };

  static Future<T> _call<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on Object catch (error) {
      throw mapToFailure(error);
    }
  }
}
