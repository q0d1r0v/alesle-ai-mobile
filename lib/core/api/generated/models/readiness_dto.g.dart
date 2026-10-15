// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readiness_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReadinessDto _$ReadinessDtoFromJson(Map<String, dynamic> json) =>
    _ReadinessDto(
      status: ReadinessDtoStatus.fromJson(json['status'] as String),
      dependencies: Map<String, String>.from(json['dependencies'] as Map),
    );

Map<String, dynamic> _$ReadinessDtoToJson(_ReadinessDto instance) =>
    <String, dynamic>{
      'status': instance.status.toJson(),
      'dependencies': instance.dependencies,
    };
