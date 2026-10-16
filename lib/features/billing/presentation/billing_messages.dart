import 'package:flutter/material.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../core/errors/failure.dart';
import '../domain/billing.dart';

/// The sentence for a failed billing call.
String billingFailureMessage(AppLocalizations l10n, Object error) {
  return switch (error) {
    NetworkFailure() => l10n.errorNetwork,
    ServerFailure(:final code, :final statusCode) => l10n.errorServer(
      code.json ?? 'HTTP ${statusCode ?? '?'}',
    ),
    _ => l10n.errorUnexpected,
  };
}

/// A plan's or pack's name as users see it.
String productName(AppLocalizations l10n, String code) => switch (code) {
  'free' => l10n.billingPlanFree,
  'pro' => 'Pro',
  'max' => 'Max',
  _ when code.startsWith('pack') => l10n.billingPackTitle,
  _ => code.isEmpty ? code : code[0].toUpperCase() + code.substring(1),
};

String methodName(AppLocalizations l10n, PayMethod method) => switch (method) {
  PayMethod.payme => 'Payme',
  PayMethod.click => 'Click',
  PayMethod.atmos => l10n.billingMethodCard,
};

String billingDate(BuildContext context, DateTime value) =>
    MaterialLocalizations.of(context).formatMediumDate(value.toLocal());
