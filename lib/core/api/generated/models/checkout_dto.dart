// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

import 'payment_provider_name.dart';

part 'checkout_dto.freezed.dart';
part 'checkout_dto.g.dart';

@Freezed()
abstract class CheckoutDto with _$CheckoutDto {
  const factory CheckoutDto({
    required String product,
    required PaymentProviderName provider,
    required String language,
  }) = _CheckoutDto;

  factory CheckoutDto.fromJson(Map<String, Object?> json) =>
      _$CheckoutDtoFromJson(json);
}
