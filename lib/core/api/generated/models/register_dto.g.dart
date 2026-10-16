// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RegisterDto _$RegisterDtoFromJson(Map<String, dynamic> json) => _RegisterDto(
  email: json['email'] as String,
  password: json['password'] as String,
  deviceName: json['deviceName'] as String?,
  locale: json['locale'] as String?,
  displayName: json['displayName'] as String?,
);

Map<String, dynamic> _$RegisterDtoToJson(_RegisterDto instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'deviceName': instance.deviceName,
      'locale': instance.locale,
      'displayName': instance.displayName,
    };
