// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'product_kind.dart';

part 'plan_dto.freezed.dart';
part 'plan_dto.g.dart';

@Freezed()
abstract class PlanDto with _$PlanDto {
  const factory PlanDto({
    required String code,
    required ProductKind kind,

    /// UZS, as a decimal string.
    required String priceUzs,

    /// USD for display, as a decimal string.
    required String priceUsd,

    /// Commands per day; null: no cap.
    required num? dailyCommands,

    /// Screen tasks per day; null: no cap.
    required num? dailyScreenTasks,
    required bool vision,
    required bool strongModel,
  }) = _PlanDto;

  factory PlanDto.fromJson(Map<String, Object?> json) =>
      _$PlanDtoFromJson(json);
}
