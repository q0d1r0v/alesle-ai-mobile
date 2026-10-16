// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/release_dto.dart';

part 'releases_api.g.dart';

@RestApi()
abstract class ReleasesApi {
  factory ReleasesApi(Dio dio, {String? baseUrl}) = _ReleasesApi;

  @GET('/v1/app/releases/latest')
  Future<ReleaseDto> releasesLatest();

  @GET('/v1/app/releases')
  Future<List<ReleaseDto>> releasesList({@Query('limit') num? limit = 20});
}
