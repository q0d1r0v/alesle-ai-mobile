// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'release_notes_dto.freezed.dart';
part 'release_notes_dto.g.dart';

@Freezed()
abstract class ReleaseNotesDto with _$ReleaseNotesDto {
  const factory ReleaseNotesDto({
    required String en,
    required String uz,
    required String ru,
  }) = _ReleaseNotesDto;

  factory ReleaseNotesDto.fromJson(Map<String, Object?> json) =>
      _$ReleaseNotesDtoFromJson(json);
}
