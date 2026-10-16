import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app/bootstrap/core_providers.dart';
import '../../../core/api/generated/clients/releases_api.dart';
import '../../../core/platform/generated/agent_api.g.dart';
import '../domain/update.dart';
import 'update_repository_impl.dart';

final Provider<UpdateRepository> updateRepositoryProvider =
    Provider<UpdateRepository>((Ref ref) {
      final Dio dio = ref.watch(anonymousDioProvider);
      return UpdateRepositoryImpl(
        releases: ReleasesApi(dio),
        dio: dio,
        installer: UpdateHostApi(),
        directory: getTemporaryDirectory,
      );
    });
