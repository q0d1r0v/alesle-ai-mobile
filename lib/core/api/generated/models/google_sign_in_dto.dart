// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'google_sign_in_dto.freezed.dart';
part 'google_sign_in_dto.g.dart';

@Freezed()
abstract class GoogleSignInDto with _$GoogleSignInDto {
  const factory GoogleSignInDto({
    /// ID token from Android Credential Manager.
    required String idToken,

    /// Shown in the device list.
    String? deviceName,

    /// App language (BCP-47) for emails.
    String? locale,
  }) = _GoogleSignInDto;

  factory GoogleSignInDto.fromJson(Map<String, Object?> json) =>
      _$GoogleSignInDtoFromJson(json);
}
