// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'magic_link_sign_in_dto.freezed.dart';
part 'magic_link_sign_in_dto.g.dart';

@Freezed()
abstract class MagicLinkSignInDto with _$MagicLinkSignInDto {
  const factory MagicLinkSignInDto({
    /// The token from the emailed link.
    required String token,

    /// The nonce sent with the magic-link request.
    required String nonce,

    /// Shown in the device list.
    String? deviceName,

    /// App language (BCP-47) for emails.
    String? locale,
  }) = _MagicLinkSignInDto;

  factory MagicLinkSignInDto.fromJson(Map<String, Object?> json) =>
      _$MagicLinkSignInDtoFromJson(json);
}
