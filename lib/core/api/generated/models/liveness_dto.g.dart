// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liveness_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LivenessDto _$LivenessDtoFromJson(Map<String, dynamic> json) => _LivenessDto(
  status: LivenessDtoStatus.fromJson(json['status'] as String),
  commit: json['commit'] as String,
  uptimeSeconds: json['uptimeSeconds'] as num,
);

Map<String, dynamic> _$LivenessDtoToJson(_LivenessDto instance) =>
    <String, dynamic>{
      'status': instance.status.toJson(),
      'commit': instance.commit,
      'uptimeSeconds': instance.uptimeSeconds,
    };
