// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_token_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LinkTokenDto _$LinkTokenDtoFromJson(Map<String, dynamic> json) =>
    _LinkTokenDto(
      token: json['token'] as String,
      deviceName: json['deviceName'] as String?,
      locale: json['locale'] as String?,
    );

Map<String, dynamic> _$LinkTokenDtoToJson(_LinkTokenDto instance) =>
    <String, dynamic>{
      'token': instance.token,
      'deviceName': instance.deviceName,
      'locale': instance.locale,
    };
