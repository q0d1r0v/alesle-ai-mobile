// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'payment_state.dart';

part 'payment_dto.freezed.dart';
part 'payment_dto.g.dart';

@Freezed()
abstract class PaymentDto with _$PaymentDto {
  const factory PaymentDto({
    required String id,
    required PaymentState state,
    required String product,
  }) = _PaymentDto;

  factory PaymentDto.fromJson(Map<String, Object?> json) =>
      _$PaymentDtoFromJson(json);
}
