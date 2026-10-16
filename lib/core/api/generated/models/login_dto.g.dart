// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginDto _$LoginDtoFromJson(Map<String, dynamic> json) => _LoginDto(
  email: json['email'] as String,
  password: json['password'] as String,
  deviceName: json['deviceName'] as String?,
  locale: json['locale'] as String?,
);

Map<String, dynamic> _$LoginDtoToJson(_LoginDto instance) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'deviceName': instance.deviceName,
  'locale': instance.locale,
};
