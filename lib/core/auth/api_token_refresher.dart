import 'package:dio/dio.dart';

import '../api/generated/clients/auth_api.dart';
import '../api/generated/models/refresh_dto.dart';
import '../network/dio_error_mapper.dart';
import 'session_controller.dart';

/// `POST /v1/auth/refresh` on an anonymous Dio; failures become `Failure`s.
TokenRefresher apiTokenRefresher(Dio anonymous) {
  final AuthApi api = AuthApi(anonymous);
  return (String refreshToken) async {
    try {
      return await api.authRefresh(
        body: RefreshDto(refreshToken: refreshToken),
      );
    } on Object catch (error) {
      throw mapToFailure(error);
    }
  };
}
