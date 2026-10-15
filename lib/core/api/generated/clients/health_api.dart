// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/liveness_dto.dart';
import '../models/readiness_dto.dart';

part 'health_api.g.dart';

@RestApi()
abstract class HealthApi {
  factory HealthApi(Dio dio, {String? baseUrl}) = _HealthApi;

  @GET('/v1/health/live')
  Future<LivenessDto> healthLive();

  @GET('/v1/health/ready')
  Future<ReadinessDto> healthReady();
}
