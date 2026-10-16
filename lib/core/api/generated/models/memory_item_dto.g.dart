// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MemoryItemDto _$MemoryItemDtoFromJson(Map<String, dynamic> json) =>
    _MemoryItemDto(
      id: json['id'] as String,
      kind: MemoryKind.fromJson(json['kind'] as String),
      content: json['content'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$MemoryItemDtoToJson(_MemoryItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': instance.kind.toJson(),
      'content': instance.content,
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
