// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'release_notes_dto.dart';

part 'release_dto.freezed.dart';
part 'release_dto.g.dart';

@Freezed()
abstract class ReleaseDto with _$ReleaseDto {
  const factory ReleaseDto({
    required num versionCode,
    required String versionName,
    required String apkUrl,

    /// Lowercase hex SHA-256 of the APK file.
    required String sha256,

    /// Lowercase hex SHA-256 of the signing certificate.
    required String certSha256,
    required num sizeBytes,

    /// Older version codes must update before using the app (EC-15).
    required num minSupportedVersionCode,
    required ReleaseNotesDto notes,
    required DateTime publishedAt,
  }) = _ReleaseDto;

  factory ReleaseDto.fromJson(Map<String, Object?> json) =>
      _$ReleaseDtoFromJson(json);
}
