// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_sign_in_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GoogleSignInDto _$GoogleSignInDtoFromJson(Map<String, dynamic> json) =>
    _GoogleSignInDto(
      idToken: json['idToken'] as String,
      deviceName: json['deviceName'] as String?,
      locale: json['locale'] as String?,
    );

Map<String, dynamic> _$GoogleSignInDtoToJson(_GoogleSignInDto instance) =>
    <String, dynamic>{
      'idToken': instance.idToken,
      'deviceName': instance.deviceName,
      'locale': instance.locale,
    };
