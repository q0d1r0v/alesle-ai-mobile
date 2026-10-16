// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

part 'checkout_result_dto.freezed.dart';
part 'checkout_result_dto.g.dart';

@Freezed()
abstract class CheckoutResultDto with _$CheckoutResultDto {
  const factory CheckoutResultDto({
    required String paymentId,

    /// The provider’s page, to open in Custom Tabs.
    required String url,
  }) = _CheckoutResultDto;

  factory CheckoutResultDto.fromJson(Map<String, Object?> json) =>
      _$CheckoutResultDtoFromJson(json);
}
