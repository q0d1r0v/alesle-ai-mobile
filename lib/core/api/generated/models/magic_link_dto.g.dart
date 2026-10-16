// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'magic_link_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MagicLinkDto _$MagicLinkDtoFromJson(Map<String, dynamic> json) =>
    _MagicLinkDto(
      email: json['email'] as String,
      nonce: json['nonce'] as String,
      locale: json['locale'] as String?,
    );

Map<String, dynamic> _$MagicLinkDtoToJson(_MagicLinkDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'nonce': instance.nonce,
      'locale': instance.locale,
    };
