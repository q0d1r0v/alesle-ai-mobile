// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileDto _$ProfileDtoFromJson(Map<String, dynamic> json) => _ProfileDto(
  id: json['id'] as String,
  email: json['email'] as String,
  emailVerified: json['emailVerified'] as bool,
  displayName: json['displayName'] as String?,
  language: ProfileLanguage.fromJson(json['language'] as String),
  timeZone: json['timeZone'] as String,
  confirmSensitiveActions: json['confirmSensitiveActions'] as bool,
  hasPassword: json['hasPassword'] as bool,
  googleLinked: json['googleLinked'] as bool,
  deletionScheduledAt: json['deletionScheduledAt'] == null
      ? null
      : DateTime.parse(json['deletionScheduledAt'] as String),
);

Map<String, dynamic> _$ProfileDtoToJson(_ProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'emailVerified': instance.emailVerified,
      'displayName': instance.displayName,
      'language': instance.language.toJson(),
      'timeZone': instance.timeZone,
      'confirmSensitiveActions': instance.confirmSensitiveActions,
      'hasPassword': instance.hasPassword,
      'googleLinked': instance.googleLinked,
      'deletionScheduledAt': instance.deletionScheduledAt?.toIso8601String(),
    };
