// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ReleaseDto _$ReleaseDtoFromJson(Map<String, dynamic> json) => _ReleaseDto(
  versionCode: json['versionCode'] as num,
  versionName: json['versionName'] as String,
  apkUrl: json['apkUrl'] as String,
  sha256: json['sha256'] as String,
  certSha256: json['certSha256'] as String,
  sizeBytes: json['sizeBytes'] as num,
  minSupportedVersionCode: json['minSupportedVersionCode'] as num,
  notes: ReleaseNotesDto.fromJson(json['notes'] as Map<String, dynamic>),
  publishedAt: DateTime.parse(json['publishedAt'] as String),
);

Map<String, dynamic> _$ReleaseDtoToJson(_ReleaseDto instance) =>
    <String, dynamic>{
      'versionCode': instance.versionCode,
      'versionName': instance.versionName,
      'apkUrl': instance.apkUrl,
      'sha256': instance.sha256,
      'certSha256': instance.certSha256,
      'sizeBytes': instance.sizeBytes,
      'minSupportedVersionCode': instance.minSupportedVersionCode,
      'notes': instance.notes.toJson(),
      'publishedAt': instance.publishedAt.toIso8601String(),
    };
