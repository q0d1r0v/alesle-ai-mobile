/// What the assistant remembers (SOW 05 §7).
enum MemoryKind { preference, contactAlias, fact, episode }

final class MemoryEntry {
  const MemoryEntry({
    required this.id,
    required this.kind,
    required this.content,
    required this.updatedAt,
  });

  final String id;
  final MemoryKind kind;
  final String content;
  final DateTime updatedAt;
}

/// How a past task ended.
enum PastTaskStatus { done, failed, cannot, stopped, interrupted }

final class PastTask {
  const PastTask({
    required this.id,
    required this.title,
    required this.status,
    required this.command,
    required this.reply,
    required this.createdAt,
  });

  final String id;
  final String? title;
  final PastTaskStatus status;

  /// What the user said; null once only a summary is kept (90 days).
  final String? command;
  final String? reply;
  final DateTime createdAt;
}

final class HistoryPage {
  const HistoryPage({required this.tasks, required this.next});

  final List<PastTask> tasks;

  /// Pass to the next call; null on the last page.
  final DateTime? next;
}

/// Throws a `Failure` from core/errors.
abstract interface class MemoryRepository {
  Future<List<MemoryEntry>> memories();

  Future<void> forget(String id);

  /// AC-MEM-3: the next command uses none of it.
  Future<void> forgetAll();

  Future<HistoryPage> history({DateTime? before});

  Future<void> removeTask(String id);

  Future<void> clearHistory();
}
