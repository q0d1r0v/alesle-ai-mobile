// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'magic_link_dto.freezed.dart';
part 'magic_link_dto.g.dart';

@Freezed()
abstract class MagicLinkDto with _$MagicLinkDto {
  const factory MagicLinkDto({
    required String email,

    /// Random value this phone keeps; the link signs in only with it, so a link sent by someone else cannot.
    required String nonce,
    String? locale,
  }) = _MagicLinkDto;

  factory MagicLinkDto.fromJson(Map<String, Object?> json) =>
      _$MagicLinkDtoFromJson(json);
}
