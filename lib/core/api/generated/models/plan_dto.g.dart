// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlanDto _$PlanDtoFromJson(Map<String, dynamic> json) => _PlanDto(
  code: json['code'] as String,
  kind: ProductKind.fromJson(json['kind'] as String),
  priceUzs: json['priceUzs'] as String,
  priceUsd: json['priceUsd'] as String,
  dailyCommands: json['dailyCommands'] as num?,
  dailyScreenTasks: json['dailyScreenTasks'] as num?,
  vision: json['vision'] as bool,
  strongModel: json['strongModel'] as bool,
);

Map<String, dynamic> _$PlanDtoToJson(_PlanDto instance) => <String, dynamic>{
  'code': instance.code,
  'kind': instance.kind.toJson(),
  'priceUzs': instance.priceUzs,
  'priceUsd': instance.priceUsd,
  'dailyCommands': instance.dailyCommands,
  'dailyScreenTasks': instance.dailyScreenTasks,
  'vision': instance.vision,
  'strongModel': instance.strongModel,
};
