import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../app/l10n/l10n.dart';
import '../../../app/router/app_router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/widgets/capsule_button.dart';
import '../../../app/widgets/grouped_card.dart';
import '../data/billing_data_providers.dart';
import '../domain/billing.dart';
import 'billing_messages.dart';
import 'billing_providers.dart';
import 'usage_bar.dart';

/// The user's plan, this month's usage, plans and the extra pack
/// (SOW 07 §6). Paying happens on the provider's page.
class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  bool _busy = false;

  void _say(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  Future<void> _setRenewal({required bool renew, required DateTime end}) async {
    final AppLocalizations l10n = context.l10n;
    if (!renew) {
      final bool? sure = await showDialog<bool>(
        context: context,
        builder: (BuildContext dialog) => AlertDialog(
          title: Text(l10n.billingCancelTitle),
          content: Text(l10n.billingCancelBody(billingDate(context, end))),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialog).pop(false),
              child: Text(l10n.commonCancel),
            ),
            TextButton(
              key: const Key('plan-cancel-confirm'),
              style: TextButton.styleFrom(foregroundColor: AlesleColors.danger),
              onPressed: () => Navigator.of(dialog).pop(true),
              child: Text(l10n.billingCancel),
            ),
          ],
        ),
      );
      if (sure != true) return;
    }
    if (_busy) return;
    setState(() => _busy = true);
    final BillingRepository repository = ref.read(billingRepositoryProvider);
    try {
      await (renew ? repository.resume() : repository.cancel());
      ref.invalidate(billingOverviewProvider);
    } on Object catch (error) {
      if (mounted) _say(billingFailureMessage(l10n, error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _buy(Product product) =>
      unawaited(context.push(AppRoutes.payFor(product.code)));

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final AsyncValue<BillingOverview> overview = ref.watch(
      billingOverviewProvider,
    );
    return Scaffold(
      appBar: AppBar(title: Text(l10n.billingTitle)),
      body: switch (overview) {
        AsyncValue<BillingOverview>(:final BillingOverview value)
            when overview.hasValue =>
          RefreshIndicator(
            onRefresh: () => ref.refresh(billingOverviewProvider.future),
            child: _content(context, value),
          ),
        AsyncValue<BillingOverview>(:final Object error)
            when overview.hasError =>
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  billingFailureMessage(l10n, error),
                  key: const Key('plan-error'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  key: const Key('plan-retry'),
                  onPressed: () => ref.invalidate(billingOverviewProvider),
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _content(BuildContext context, BillingOverview overview) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme text = Theme.of(context).textTheme;
    final BillingStatus status = overview.status;
    final Product? pack = overview.pack;
    final bool paid = status.subscription == SubscriptionState.active;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        32 + MediaQuery.paddingOf(context).bottom,
      ),
      children: <Widget>[
        AlesleCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  productName(l10n, status.planCode),
                  key: const Key('plan-current'),
                  style: text.headlineSmall,
                ),
                const SizedBox(height: 14),
                UsageBar(
                  percent: status.usedPercent,
                  out: status.level == UsageLevel.out,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.billingUsed(status.usedPercent),
                  key: const Key('plan-used'),
                  style: text.bodyMedium,
                ),
                Text(
                  l10n.billingResets(billingDate(context, status.periodEnd)),
                  style: text.bodySmall?.copyWith(color: AlesleColors.text2),
                ),
                if (status.level == UsageLevel.out) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    l10n.billingSimpleMode,
                    key: const Key('plan-simple'),
                    style: text.bodyMedium?.copyWith(
                      color: AlesleColors.notDoneBottom,
                    ),
                  ),
                ],
                if (status.subscription ==
                    SubscriptionState.pastDue) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    l10n.billingPastDue,
                    key: const Key('plan-past-due'),
                    style: text.bodyMedium?.copyWith(
                      color: AlesleColors.danger,
                    ),
                  ),
                ],
                if (paid) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    status.cancelAtPeriodEnd
                        ? l10n.billingEndsOn(
                            billingDate(context, status.periodEnd),
                          )
                        : l10n.billingPaidUntil(
                            billingDate(context, status.periodEnd),
                          ),
                    key: const Key('plan-renewal'),
                    style: text.bodyMedium,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      key: const Key('plan-renewal-toggle'),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: _busy
                          ? null
                          : () => unawaited(
                              _setRenewal(
                                renew: status.cancelAtPeriodEnd,
                                end: status.periodEnd,
                              ),
                            ),
                      child: Text(
                        status.cancelAtPeriodEnd
                            ? l10n.billingResume
                            : l10n.billingCancel,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (pack != null) ...<Widget>[
          const SizedBox(height: 16),
          AlesleCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(l10n.billingPackTitle, style: text.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    l10n.billingPackBody,
                    style: text.bodyMedium?.copyWith(color: AlesleColors.text2),
                  ),
                  const SizedBox(height: 14),
                  CapsuleButton(
                    key: const Key('plan-pack'),
                    label: l10n.billingAddMore(formatSum(pack.priceUzs)),
                    style: status.level == UsageLevel.normal
                        ? CapsuleStyle.secondary
                        : CapsuleStyle.primary,
                    onPressed: () => _buy(pack),
                  ),
                ],
              ),
            ),
          ),
        ],
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
          child: Text(
            l10n.billingPlans,
            style: text.labelLarge?.copyWith(color: AlesleColors.text2),
          ),
        ),
        for (final Product plan in overview.plans)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PlanCard(
              plan: plan,
              current: plan.code == status.planCode && paid,
              onChoose: () => _buy(plan),
            ),
          ),
      ],
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.current,
    required this.onChoose,
  });

  final Product plan;
  final bool current;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final TextTheme text = Theme.of(context).textTheme;
    final List<String> features = <String>[
      if (plan.dailyCommands case final int n)
        l10n.billingFeatureDaily(n)
      else
        l10n.billingFeatureNoDaily,
      if (plan.dailyScreenTasks case final int n)
        l10n.billingFeatureScreenDaily(n),
      if (plan.vision) l10n.billingFeatureVision,
      if (plan.strongModel) l10n.billingFeatureStrong,
    ];
    return AlesleCard(
      key: Key('plan-${plan.code}'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    productName(l10n, plan.code),
                    style: text.titleLarge,
                  ),
                ),
                if (current)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: AlesleColors.violet.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AlesleRadii.capsule),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        l10n.billingCurrent,
                        style: text.labelMedium?.copyWith(
                          color: AlesleColors.violet,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.billingPerMonth(formatSum(plan.priceUzs)),
              style: text.bodyLarge?.copyWith(color: AlesleColors.text2),
            ),
            const SizedBox(height: 12),
            for (final String feature in features)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: AlesleColors.doneBottom,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature, style: text.bodyMedium)),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            CapsuleButton(
              key: Key('plan-choose-${plan.code}'),
              label: current ? l10n.billingExtend : l10n.billingChoose,
              style: current ? CapsuleStyle.secondary : CapsuleStyle.primary,
              onPressed: onChoose,
            ),
          ],
        ),
      ),
    );
  }
}
