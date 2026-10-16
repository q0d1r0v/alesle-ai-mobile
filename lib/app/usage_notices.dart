import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_session.dart';
import '../core/storage/app_settings.dart';
import '../features/billing/data/billing_data_providers.dart';
import '../features/billing/domain/billing.dart';
import '../features/home/presentation/home_task_controller.dart';
import 'account_links.dart';
import 'bootstrap/core_providers.dart';
import 'l10n/app_localizations.dart';
import 'router/app_router.dart';

/// This period's usage, told once per period (SOW 07 §6): a reminder at
/// 80 %, the limit screen when it is used up. Checked at start, on sign-in,
/// when the app comes back and after each task.
class UsageNotices extends ConsumerStatefulWidget {
  const UsageNotices({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<UsageNotices> createState() => _UsageNoticesState();
}

class _UsageNoticesState extends ConsumerState<UsageNotices> {
  late final AppLifecycleListener _lifecycle;
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
    if (_checking || !mounted || ref.read(sessionProvider) == null) return;
    _checking = true;
    try {
      final BillingStatus status = await ref
          .read(billingRepositoryProvider)
          .status();
      if (!mounted) return;
      final String? key = usageNoticeKey(status);
      if (key == null || key == ref.read(appSettingsProvider).usageNoticeKey) {
        return;
      }
      await ref
          .read(appSettingsProvider.notifier)
          .update((AppSettings s) => s.copyWith(usageNoticeKey: key));
      if (!mounted) return;
      _tell(status);
    } on Object {
      // Offline or signed out meanwhile: the next check tells.
    } finally {
      _checking = false;
    }
  }

  void _tell(BillingStatus status) {
    final GoRouter router = ref.read(routerProvider);
    final String here = router.routerDelegate.currentConfiguration.uri.path;
    final ScaffoldMessengerState? messenger = appMessengerKey.currentState;
    if (status.level == UsageLevel.out) {
      // An older notice must not sit under the limit screen.
      messenger?.hideCurrentSnackBar();
      // A refused task may have opened it already.
      if (here != AppRoutes.limit) {
        unawaited(router.push(AppRoutes.limitFor('limit_reached')));
      }
      return;
    }
    final AppLocalizations? l10n = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    if (messenger == null || l10n == null) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const Key('usage-notice'),
          content: Text(l10n.usageHighNotice(status.usedPercent)),
          action: SnackBarAction(
            label: l10n.billingTitle,
            onPressed: () => unawaited(router.push(AppRoutes.plan)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    ref
      ..listen<AuthSession?>(sessionProvider, (
        AuthSession? before,
        AuthSession? now,
      ) {
        if (before == null && now != null) unawaited(_check());
      })
      ..listen<HomeTask>(homeTaskProvider, (HomeTask? before, HomeTask now) {
        if (now is TaskResult && before is! TaskResult) unawaited(_check());
      });
    return widget.child;
  }
}
