import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/update_data_providers.dart';
import '../domain/update.dart';

/// Where the download-and-install of an update is.
sealed class UpdateFlow {
  const UpdateFlow();
}

final class UpdateIdle extends UpdateFlow {
  const UpdateIdle();
}

final class UpdateDownloading extends UpdateFlow {
  const UpdateDownloading(this.progress);

  /// 0–1.
  final double progress;
}

final class UpdateInstalling extends UpdateFlow {
  const UpdateInstalling();
}

final class UpdateFinished extends UpdateFlow {
  const UpdateFinished(this.result);

  final InstallResult result;
}

/// Downloads the release and hands it to the installer, once at a time.
class UpdateController extends Notifier<UpdateFlow> {
  @override
  UpdateFlow build() => const UpdateIdle();

  bool get busy => state is UpdateDownloading || state is UpdateInstalling;

  Future<void> run(Release release) async {
    if (busy) return;
    final UpdateRepository repository = ref.read(updateRepositoryProvider);
    state = const UpdateDownloading(0);
    try {
      final String path = await repository.download(
        release,
        progress: (double value) {
          if (state is UpdateDownloading) state = UpdateDownloading(value);
        },
      );
      state = const UpdateInstalling();
      state = UpdateFinished(await repository.install(release, path));
    } on Object {
      state = const UpdateFinished(InstallResult.failed);
    }
  }
}

final NotifierProvider<UpdateController, UpdateFlow> updateFlowProvider =
    NotifierProvider<UpdateController, UpdateFlow>(UpdateController.new);

/// The newest release; re-read on demand (`ref.invalidate`).
final FutureProvider<Release?> latestReleaseProvider =
    FutureProvider.autoDispose<Release?>(
      (Ref ref) => ref.watch(updateRepositoryProvider).latest(),
    );
