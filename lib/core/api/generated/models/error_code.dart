// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum ErrorCode {
  @JsonValue('BAD_REQUEST')
  badRequest('BAD_REQUEST'),
  @JsonValue('VALIDATION_FAILED')
  validationFailed('VALIDATION_FAILED'),
  @JsonValue('UNAUTHENTICATED')
  unauthenticated('UNAUTHENTICATED'),
  @JsonValue('FORBIDDEN')
  forbidden('FORBIDDEN'),
  @JsonValue('NOT_FOUND')
  notFound('NOT_FOUND'),
  @JsonValue('METHOD_NOT_ALLOWED')
  methodNotAllowed('METHOD_NOT_ALLOWED'),
  @JsonValue('CONFLICT')
  conflict('CONFLICT'),
  @JsonValue('PAYLOAD_TOO_LARGE')
  payloadTooLarge('PAYLOAD_TOO_LARGE'),
  @JsonValue('RATE_LIMITED')
  rateLimited('RATE_LIMITED'),
  @JsonValue('SERVICE_UNAVAILABLE')
  serviceUnavailable('SERVICE_UNAVAILABLE'),
  @JsonValue('VOICE_UNAVAILABLE')
  voiceUnavailable('VOICE_UNAVAILABLE'),
  @JsonValue('INVALID_CREDENTIALS')
  invalidCredentials('INVALID_CREDENTIALS'),
  @JsonValue('EMAIL_TAKEN')
  emailTaken('EMAIL_TAKEN'),
  @JsonValue('LINK_INVALID')
  linkInvalid('LINK_INVALID'),
  @JsonValue('SESSION_EXPIRED')
  sessionExpired('SESSION_EXPIRED'),
  @JsonValue('GOOGLE_TOKEN_INVALID')
  googleTokenInvalid('GOOGLE_TOKEN_INVALID'),
  @JsonValue('SIGN_IN_METHOD_UNAVAILABLE')
  signInMethodUnavailable('SIGN_IN_METHOD_UNAVAILABLE'),
  @JsonValue('PAYMENT_PROVIDER_UNAVAILABLE')
  paymentProviderUnavailable('PAYMENT_PROVIDER_UNAVAILABLE'),
  @JsonValue('UPGRADE_REQUIRED')
  upgradeRequired('UPGRADE_REQUIRED'),
  @JsonValue('INTERNAL')
  internal('INTERNAL'),

  /// Default value for all unparsed values, allows backward compatibility when adding new values on the backend.
  $unknown(null);

  const ErrorCode(this.json);

  factory ErrorCode.fromJson(String json) =>
      values.firstWhere((e) => e.json == json, orElse: () => $unknown);

  final String? json;
  String toJson() {
    final value = json;
    if (value == null) {
      throw StateError(
        'Cannot convert enum value with null JSON representation to String. '
        'This usually happens for \$unknown or @JsonValue(null) entries.',
      );
    }
    return value as String;
  }

  @override
  String toString() => json?.toString() ?? super.toString();

  /// Returns all defined enum values excluding the $unknown value.
  static List<ErrorCode> get $valuesDefined =>
      values.where((value) => value != $unknown).toList();
}
