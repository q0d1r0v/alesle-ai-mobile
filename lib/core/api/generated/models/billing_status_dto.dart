// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'billing_status_dto_providers.dart';
import 'billing_status_dto_subscription_status.dart';

part 'billing_status_dto.freezed.dart';
part 'billing_status_dto.g.dart';

@Freezed()
abstract class BillingStatusDto with _$BillingStatusDto {
  const factory BillingStatusDto({
    required String plan,

    /// Share of this period’s allowance used, 0–100 (D9).
    required num usedPercent,

    /// Allowance used up: simple mode until the period ends.
    required bool simple,
    required DateTime periodEnd,

    /// Paid plan state; null on Free.
    required BillingStatusDtoSubscriptionStatus? subscriptionStatus,
    required bool cancelAtPeriodEnd,

    /// Payment methods set up here.
    required List<BillingStatusDtoProviders> providers,
  }) = _BillingStatusDto;

  factory BillingStatusDto.fromJson(Map<String, Object?> json) =>
      _$BillingStatusDtoFromJson(json);
}
