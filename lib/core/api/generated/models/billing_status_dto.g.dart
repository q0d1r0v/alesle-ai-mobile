// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_status_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BillingStatusDto _$BillingStatusDtoFromJson(Map<String, dynamic> json) =>
    _BillingStatusDto(
      plan: json['plan'] as String,
      usedPercent: json['usedPercent'] as num,
      simple: json['simple'] as bool,
      periodEnd: DateTime.parse(json['periodEnd'] as String),
      subscriptionStatus: json['subscriptionStatus'] == null
          ? null
          : BillingStatusDtoSubscriptionStatus.fromJson(
              json['subscriptionStatus'] as String,
            ),
      cancelAtPeriodEnd: json['cancelAtPeriodEnd'] as bool,
      providers: (json['providers'] as List<dynamic>)
          .map((e) => BillingStatusDtoProviders.fromJson(e as String))
          .toList(),
    );

Map<String, dynamic> _$BillingStatusDtoToJson(_BillingStatusDto instance) =>
    <String, dynamic>{
      'plan': instance.plan,
      'usedPercent': instance.usedPercent,
      'simple': instance.simple,
      'periodEnd': instance.periodEnd.toIso8601String(),
      'subscriptionStatus': instance.subscriptionStatus?.toJson(),
      'cancelAtPeriodEnd': instance.cancelAtPeriodEnd,
      'providers': instance.providers.map((e) => e.toJson()).toList(),
    };
