import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/l10n/l10n.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/capsule_button.dart';
import '../domain/billing.dart';
import 'billing_messages.dart';
import 'billing_providers.dart';

/// Why the limit screen opened: the task finish reason.
enum LimitKind {
  /// The month's allowance is used up (`limit_reached`).
  month,

  /// Free plan's daily cap (`daily_limit`).
  day;

  static LimitKind? fromReason(String? reason) => switch (reason) {
    'limit_reached' => LimitKind.month,
    'daily_limit' => LimitKind.day,
    _ => null,
  };
}

/// "This month is used up" (SOW 07 §6, D9): [Add more] [Upgrade] [Later].
class LimitScreen extends ConsumerWidget {
  const LimitScreen({required this.kind, super.key});

  final LimitKind kind;

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme text = Theme.of(context).textTheme;
    final BillingOverview? overview = ref.watch(billingOverviewProvider).value;
    final Product? pack = kind == LimitKind.month ? overview?.pack : null;
    final bool onTop = overview?.status.planCode == 'max';
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.1),
            radius: 0.9,
            colors: <Color>[Color(0x33A089F0), AlesleColors.canvas],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: IconButton.filled(
                    key: const Key('limit-close'),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AlesleColors.ink,
                    ),
                    tooltip: l10n.commonLater,
                    onPressed: () => _close(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const _FullRing(),
                          const SizedBox(height: 28),
                          Text(
                            kind == LimitKind.month
                                ? l10n.limitMonthTitle
                                : l10n.limitDailyTitle,
                            key: const Key('limit-title'),
                            style: text.headlineSmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            kind == LimitKind.month
                                ? l10n.limitMonthBody
                                : l10n.limitDailyBody,
                            style: text.bodyLarge?.copyWith(
                              color: AlesleColors.text2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (pack != null) ...<Widget>[
                  CapsuleButton(
                    key: const Key('limit-pack'),
                    label: l10n.billingAddMore(formatSum(pack.priceUzs)),
                    onPressed: () =>
                        unawaited(context.push(AppRoutes.payFor(pack.code))),
                  ),
                  const SizedBox(height: 8),
                ],
                if (!onTop) ...<Widget>[
                  CapsuleButton(
                    key: const Key('limit-upgrade'),
                    label: l10n.limitUpgrade,
                    style: pack == null
                        ? CapsuleStyle.primary
                        : CapsuleStyle.outlined,
                    onPressed: () => unawaited(context.push(AppRoutes.plan)),
                  ),
                  const SizedBox(height: 8),
                ],
                CapsuleButton(
                  key: const Key('limit-later'),
                  label: switch ((kind, overview)) {
                    (LimitKind.day, _) => l10n.limitWaitTomorrow,
                    (LimitKind.month, final BillingOverview o) =>
                      l10n.limitWaitUntil(
                        billingDate(context, o.status.periodEnd),
                      ),
                    (LimitKind.month, null) => l10n.commonLater,
                  },
                  style: CapsuleStyle.text,
                  onPressed: () => _close(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The used-up ring: a full violet circle around "100%".
class _FullRing extends StatelessWidget {
  const _FullRing();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AlesleColors.violetGradient,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Color(0x558568DB),
            blurRadius: 32,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            '100%',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
