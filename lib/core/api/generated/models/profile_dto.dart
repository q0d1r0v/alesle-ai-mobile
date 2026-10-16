// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'profile_language.dart';

part 'profile_dto.freezed.dart';
part 'profile_dto.g.dart';

@Freezed()
abstract class ProfileDto with _$ProfileDto {
  const factory ProfileDto({
    required String id,
    required String email,

    /// Confirmed by a link (EC-AU-3).
    required bool emailVerified,
    required String? displayName,
    required ProfileLanguage language,
    required String timeZone,

    /// "Confirm every sensitive action" (D11).
    required bool confirmSensitiveActions,

    /// The account can sign in with a password.
    required bool hasPassword,

    /// A Google account is linked.
    required bool googleLinked,

    /// Deletion requested: the account is erased at this time unless cancelled.
    required DateTime? deletionScheduledAt,
  }) = _ProfileDto;

  factory ProfileDto.fromJson(Map<String, Object?> json) =>
      _$ProfileDtoFromJson(json);
}
