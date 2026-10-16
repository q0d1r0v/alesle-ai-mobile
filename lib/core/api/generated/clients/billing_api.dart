// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, unused_import, invalid_annotation_target, unnecessary_import

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../models/billing_status_dto.dart';
import '../models/checkout_dto.dart';
import '../models/checkout_result_dto.dart';
import '../models/payment_dto.dart';
import '../models/plan_dto.dart';

part 'billing_api.g.dart';

@RestApi()
abstract class BillingApi {
  factory BillingApi(Dio dio, {String? baseUrl}) = _BillingApi;

  @GET('/v1/billing/plans')
  Future<List<PlanDto>> billingPlans();

  @GET('/v1/billing/status')
  Future<BillingStatusDto> billingStatus();

  @POST('/v1/billing/checkout')
  Future<CheckoutResultDto> billingCheckout({
    @Body() required CheckoutDto body,
  });

  @GET('/v1/billing/payments/{id}')
  Future<PaymentDto> billingPayment({@Path('id') required String id});

  @POST('/v1/billing/subscription/cancel')
  Future<void> billingCancel();

  @POST('/v1/billing/subscription/resume')
  Future<void> billingResume();
}
