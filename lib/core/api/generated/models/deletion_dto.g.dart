// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deletion_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeletionDto _$DeletionDtoFromJson(Map<String, dynamic> json) => _DeletionDto(
  deletionScheduledAt: DateTime.parse(json['deletionScheduledAt'] as String),
);

Map<String, dynamic> _$DeletionDtoToJson(_DeletionDto instance) =>
    <String, dynamic>{
      'deletionScheduledAt': instance.deletionScheduledAt.toIso8601String(),
    };
