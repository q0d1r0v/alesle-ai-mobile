// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/memory_item_dto.dart';

part 'memory_api.g.dart';

@RestApi()
abstract class MemoryApi {
  factory MemoryApi(Dio dio, {String? baseUrl}) = _MemoryApi;

  @GET('/v1/memory')
  Future<List<MemoryItemDto>> memoryList();

  @DELETE('/v1/memory')
  Future<void> memoryForgetAll();

  @DELETE('/v1/memory/{id}')
  Future<void> memoryRemove({@Path('id') required String id});
}
