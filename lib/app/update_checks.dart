import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_build.dart';
import '../core/storage/app_settings.dart';
import '../features/home/presentation/home_task_controller.dart';
import '../features/update/data/update_data_providers.dart';
import '../features/update/domain/update.dart';
import '../features/update/presentation/update_sheet.dart';
import 'bootstrap/core_providers.dart';
import 'router/app_router.dart';

/// Reads the release manifest when the app opens and at most daily after
/// (SOW 02 §3): a required update blocks the app (EC-15); a newer optional
/// one is offered once in the "new version" sheet.
class UpdateChecks extends ConsumerStatefulWidget {
  const UpdateChecks({required this.child, super.key, this.now = DateTime.now});

  final Widget child;
  final DateTime Function() now;

  @override
  ConsumerState<UpdateChecks> createState() => _UpdateChecksState();
}

class _UpdateChecksState extends ConsumerState<UpdateChecks> {
  late final AppLifecycleListener _lifecycle;
  DateTime? _lastCheck;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_check()));
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_check()));
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final AppBuild build = ref.read(appBuildProvider);
    final DateTime now = widget.now();
    if (_checking || !mounted || !build.known) return;
    if (!updateCheckDue(_lastCheck, now)) return;
    _checking = true;
    try {
      final Release? latest = await ref.read(updateRepositoryProvider).latest();
      _lastCheck = now;
      if (!mounted) return;
      switch (updateNeed(build.versionCode, latest)) {
        case UpdateNeed.none:
          return;
        case UpdateNeed.required:
          ref.read(upgradeRequiredProvider.notifier).require();
        case UpdateNeed.optional:
          await _offer(latest!);
      }
    } on Object {
      // Offline: the next opening checks again.
    } finally {
      _checking = false;
    }
  }

  Future<void> _offer(Release release) async {
    if (ref.read(appSettingsProvider).offeredUpdate == release.versionCode) {
      return;
    }
    final GoRouter router = ref.read(routerProvider);
    final BuildContext? context =
        router.routerDelegate.navigatorKey.currentContext;
    if (context == null) return;
    await ref
        .read(appSettingsProvider.notifier)
        .update(
          (AppSettings s) => s.copyWith(offeredUpdate: release.versionCode),
        );
    if (!context.mounted) return;
    if (await showUpdateSheet(context, release)) {
      unawaited(router.push(AppRoutes.updateNow));
    }
  }

  @override
  Widget build(BuildContext context) {
    // A task refused for this version's age shows the update screen too.
    ref.listen<HomeTask>(homeTaskProvider, (HomeTask? before, HomeTask now) {
      if (now is TaskResult && now.reason == 'upgrade_required') {
        ref.read(upgradeRequiredProvider.notifier).require();
      }
    });
    return widget.child;
  }
}
