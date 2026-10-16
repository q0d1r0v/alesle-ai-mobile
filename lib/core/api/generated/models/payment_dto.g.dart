// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentDto _$PaymentDtoFromJson(Map<String, dynamic> json) => _PaymentDto(
  id: json['id'] as String,
  state: PaymentState.fromJson(json['state'] as String),
  product: json['product'] as String,
);

Map<String, dynamic> _$PaymentDtoToJson(_PaymentDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'state': instance.state.toJson(),
      'product': instance.product,
    };
