// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/deletion_dto.dart';
import '../models/profile_dto.dart';
import '../models/session_dto.dart';
import '../models/update_profile_dto.dart';

part 'me_api.g.dart';

@RestApi()
abstract class MeApi {
  factory MeApi(Dio dio, {String? baseUrl}) = _MeApi;

  @GET('/v1/me')
  Future<ProfileDto> meProfile();

  @PATCH('/v1/me')
  Future<ProfileDto> meUpdate({@Body() required UpdateProfileDto body});

  @DELETE('/v1/me')
  Future<DeletionDto> meRequestDeletion();

  @GET('/v1/me/sessions')
  Future<List<SessionDto>> meSessions();

  @DELETE('/v1/me/sessions/{id}')
  Future<void> meRemoveSession({@Path('id') required String id});

  @POST('/v1/me/sessions/sign-out-all')
  Future<void> meSignOutEverywhere();

  @POST('/v1/me/deletion/cancel')
  Future<ProfileDto> meCancelDeletion();
}
