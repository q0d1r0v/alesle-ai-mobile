// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'locale_dto.freezed.dart';
part 'locale_dto.g.dart';

@Freezed()
abstract class LocaleDto with _$LocaleDto {
  const factory LocaleDto({
    /// Language of the email (BCP-47).
    String? locale,
  }) = _LocaleDto;

  factory LocaleDto.fromJson(Map<String, Object?> json) =>
      _$LocaleDtoFromJson(json);
}
