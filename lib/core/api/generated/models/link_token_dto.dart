// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'link_token_dto.freezed.dart';
part 'link_token_dto.g.dart';

@Freezed()
abstract class LinkTokenDto with _$LinkTokenDto {
  const factory LinkTokenDto({
    /// The token from the emailed link.
    required String token,

    /// Shown in the device list.
    String? deviceName,

    /// App language (BCP-47) for emails.
    String? locale,
  }) = _LinkTokenDto;

  factory LinkTokenDto.fromJson(Map<String, Object?> json) =>
      _$LinkTokenDtoFromJson(json);
}
