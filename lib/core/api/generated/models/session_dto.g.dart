// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SessionDto _$SessionDtoFromJson(Map<String, dynamic> json) => _SessionDto(
  id: json['id'] as String,
  deviceName: json['deviceName'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastUsedAt: DateTime.parse(json['lastUsedAt'] as String),
  current: json['current'] as bool,
);

Map<String, dynamic> _$SessionDtoToJson(_SessionDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'deviceName': instance.deviceName,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastUsedAt': instance.lastUsedAt.toIso8601String(),
      'current': instance.current,
    };
