// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CheckoutDto _$CheckoutDtoFromJson(Map<String, dynamic> json) => _CheckoutDto(
  product: json['product'] as String,
  provider: PaymentProviderName.fromJson(json['provider'] as String),
  language: json['language'] as String,
);

Map<String, dynamic> _$CheckoutDtoToJson(_CheckoutDto instance) =>
    <String, dynamic>{
      'product': instance.product,
      'provider': instance.provider.toJson(),
      'language': instance.language,
    };
