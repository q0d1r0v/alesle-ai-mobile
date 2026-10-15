// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_body_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ErrorBodyDto _$ErrorBodyDtoFromJson(Map<String, dynamic> json) =>
    _ErrorBodyDto(
      code: ErrorCode.fromJson(json['code'] as String),
      message: json['message'] as String,
      requestId: json['requestId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      details: json['details'],
    );

Map<String, dynamic> _$ErrorBodyDtoToJson(_ErrorBodyDto instance) =>
    <String, dynamic>{
      'code': instance.code.toJson(),
      'message': instance.message,
      'requestId': instance.requestId,
      'timestamp': instance.timestamp.toIso8601String(),
      'details': instance.details,
    };
