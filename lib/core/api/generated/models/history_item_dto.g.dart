// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HistoryItemDto _$HistoryItemDtoFromJson(Map<String, dynamic> json) =>
    _HistoryItemDto(
      id: json['id'] as String,
      title: json['title'] as String?,
      status: TaskStatus.fromJson(json['status'] as String),
      command: json['command'] as String?,
      reply: json['reply'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$HistoryItemDtoToJson(_HistoryItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'status': instance.status.toJson(),
      'command': instance.command,
      'reply': instance.reply,
      'createdAt': instance.createdAt.toIso8601String(),
    };
