// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'magic_link_sign_in_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MagicLinkSignInDto _$MagicLinkSignInDtoFromJson(Map<String, dynamic> json) =>
    _MagicLinkSignInDto(
      token: json['token'] as String,
      nonce: json['nonce'] as String,
      deviceName: json['deviceName'] as String?,
      locale: json['locale'] as String?,
    );

Map<String, dynamic> _$MagicLinkSignInDtoToJson(_MagicLinkSignInDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'nonce': instance.nonce,
      'deviceName': instance.deviceName,
      'locale': instance.locale,
    };
