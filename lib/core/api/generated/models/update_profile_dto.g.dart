// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateProfileDto _$UpdateProfileDtoFromJson(Map<String, dynamic> json) =>
    _UpdateProfileDto(
      displayName: json['displayName'] as String?,
      language: json['language'] == null
          ? null
          : ProfileLanguage.fromJson(json['language'] as String),
      timeZone: json['timeZone'] as String?,
      confirmSensitiveActions: json['confirmSensitiveActions'] as bool?,
    );

Map<String, dynamic> _$UpdateProfileDtoToJson(_UpdateProfileDto instance) =>
    <String, dynamic>{
      'displayName': instance.displayName,
      'language': instance.language?.toJson(),
      'timeZone': instance.timeZone,
      'confirmSensitiveActions': instance.confirmSensitiveActions,
    };
