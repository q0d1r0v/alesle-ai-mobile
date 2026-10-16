import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/bootstrap/core_providers.dart';
import '../../../core/api/generated/clients/history_api.dart';
import '../../../core/api/generated/clients/memory_api.dart';
import '../domain/memory.dart';
import 'memory_repository_impl.dart';

final Provider<MemoryRepository> memoryRepositoryProvider =
    Provider<MemoryRepository>(
      (Ref ref) => MemoryRepositoryImpl(
        memory: MemoryApi(ref.watch(dioProvider)),
        history: HistoryApi(ref.watch(dioProvider)),
      ),
    );
