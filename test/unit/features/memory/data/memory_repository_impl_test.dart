import 'package:alesle_ai/core/api/generated/clients/history_api.dart';
import 'package:alesle_ai/core/api/generated/clients/memory_api.dart';
import 'package:alesle_ai/core/api/generated/models/history_item_dto.dart';
import 'package:alesle_ai/core/api/generated/models/history_page_dto.dart';
import 'package:alesle_ai/core/api/generated/models/memory_item_dto.dart';
import 'package:alesle_ai/core/api/generated/models/memory_kind.dart' as api;
import 'package:alesle_ai/core/api/generated/models/task_status.dart';
import 'package:alesle_ai/core/errors/failure.dart';
import 'package:alesle_ai/features/memory/data/memory_repository_impl.dart';
import 'package:alesle_ai/features/memory/domain/memory.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMemoryApi extends Mock implements MemoryApi {}

class _MockHistoryApi extends Mock implements HistoryApi {}

void main() {
  late _MockMemoryApi memory;
  late _MockHistoryApi history;
  late MemoryRepositoryImpl repository;

  setUp(() {
    memory = _MockMemoryApi();
    history = _MockHistoryApi();
    repository = MemoryRepositoryImpl(memory: memory, history: history);
  });

  test('maps memories of every kind', () async {
    when(memory.memoryList).thenAnswer(
      (_) async => <MemoryItemDto>[
        for (final api.MemoryKind kind in api.MemoryKind.values)
          MemoryItemDto(
            id: kind.name,
            kind: kind,
            content: 'c',
            updatedAt: DateTime(2026),
          ),
      ],
    );
    final List<MemoryEntry> entries = await repository.memories();
    expect(entries.map((e) => e.kind), <MemoryKind>[
      MemoryKind.preference,
      MemoryKind.contactAlias,
      MemoryKind.fact,
      MemoryKind.episode,
      MemoryKind.fact,
    ]);
  });

  test('forgets one and all', () async {
    when(() => memory.memoryRemove(id: 'm1')).thenAnswer((_) async {});
    when(memory.memoryForgetAll).thenAnswer((_) async {});
    await repository.forget('m1');
    await repository.forgetAll();
    verify(() => memory.memoryRemove(id: 'm1')).called(1);
    verify(memory.memoryForgetAll).called(1);
  });

  test('pages history and maps every status', () async {
    when(() => history.historyList(before: any(named: 'before'), limit: 20))
        .thenAnswer(
          (_) async => HistoryPageDto(
            items: <HistoryItemDto>[
              for (final TaskStatus status in TaskStatus.values)
                HistoryItemDto(
                  id: status.name,
                  title: 't',
                  status: status,
                  command: 'c',
                  reply: null,
                  createdAt: DateTime(2026),
                ),
            ],
            next: DateTime(2026),
          ),
        );
    final HistoryPage page = await repository.history(before: DateTime(2027));
    expect(page.next, DateTime(2026));
    expect(page.tasks.map((t) => t.status), <PastTaskStatus>[
      PastTaskStatus.done,
      PastTaskStatus.failed,
      PastTaskStatus.cannot,
      PastTaskStatus.stopped,
      PastTaskStatus.interrupted,
      PastTaskStatus.failed,
    ]);
    verify(() => history.historyList(before: DateTime(2027), limit: 20))
        .called(1);
  });

  test('removes and clears history; failures become Failures', () async {
    when(() => history.historyRemove(id: 't1')).thenAnswer((_) async {});
    when(history.historyClear).thenAnswer((_) async {});
    await repository.removeTask('t1');
    await repository.clearHistory();

    when(memory.memoryList).thenThrow(
      DioException.connectionError(
        requestOptions: RequestOptions(path: '/v1/memory'),
        reason: 'offline',
      ),
    );
    await expectLater(repository.memories(), throwsA(isA<NetworkFailure>()));
  });
}
