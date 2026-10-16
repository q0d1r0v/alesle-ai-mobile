// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/google_sign_in_dto.dart';
import '../models/link_token_dto.dart';
import '../models/locale_dto.dart';
import '../models/login_dto.dart';
import '../models/magic_link_dto.dart';
import '../models/magic_link_sign_in_dto.dart';
import '../models/refresh_dto.dart';
import '../models/register_dto.dart';
import '../models/token_pair_dto.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class AuthApi {
  factory AuthApi(Dio dio, {String? baseUrl}) = _AuthApi;

  @POST('/v1/auth/register')
  Future<TokenPairDto> authRegister({@Body() required RegisterDto body});

  @POST('/v1/auth/login')
  Future<TokenPairDto> authLogin({@Body() required LoginDto body});

  @POST('/v1/auth/google')
  Future<TokenPairDto> authGoogle({@Body() required GoogleSignInDto body});

  @POST('/v1/auth/magic-link')
  Future<void> authMagicLink({@Body() required MagicLinkDto body});

  @POST('/v1/auth/magic-link/verify')
  Future<TokenPairDto> authVerifyMagicLink({
    @Body() required MagicLinkSignInDto body,
  });

  @POST('/v1/auth/email/verify')
  Future<void> authVerifyEmail({@Body() required LinkTokenDto body});

  @POST('/v1/auth/email/resend')
  Future<void> authResendVerification({@Body() required LocaleDto body});

  @POST('/v1/auth/refresh')
  Future<TokenPairDto> authRefresh({@Body() required RefreshDto body});

  @POST('/v1/auth/logout')
  Future<void> authLogout();
}
