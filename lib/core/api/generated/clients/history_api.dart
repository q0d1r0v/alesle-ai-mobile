// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/history_page_dto.dart';

part 'history_api.g.dart';

@RestApi()
abstract class HistoryApi {
  factory HistoryApi(Dio dio, {String? baseUrl}) = _HistoryApi;

  @GET('/v1/history')
  Future<HistoryPageDto> historyList({
    @Query('before') DateTime? before,
    @Query('limit') num? limit = 20,
  });

  @DELETE('/v1/history')
  Future<void> historyClear();

  @DELETE('/v1/history/{id}')
  Future<void> historyRemove({@Path('id') required String id});
}
