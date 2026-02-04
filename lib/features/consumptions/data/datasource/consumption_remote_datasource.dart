import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class ConsumptionRemoteDatasource {
  Future<String> respondConsumptionConfirmation({
    required String confirmationId,
    required String responseText,
    required String actualQuantityRemaining,
  });
  Future<List<Map<String, dynamic>>> getConsumptionConfirmationPending({
    required String kitchenId,
  });
  Future<String> getConsumptionConfirmationCount({required String kitchenId});
}

class ConsumptionRemoteDatasourceImpl implements ConsumptionRemoteDatasource {
  final DioHelper dio;
  ConsumptionRemoteDatasourceImpl(this.dio);

  @override
  Future<List<Map<String, dynamic>>> getConsumptionConfirmationPending({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.consumptionConfirmationPending}?kitchen_id=$kitchenId",
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      return List<Map<String, dynamic>>.from(data['confirmations']);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> respondConsumptionConfirmation({
    required String confirmationId,
    required String responseText,
    required String actualQuantityRemaining,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.consumptionConfirmationRespond,
        data: {"confirmation_id": confirmationId, "response": responseText},
      );
      log("dio error: ${response.toString()} ${response.statusCode}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> getConsumptionConfirmationCount({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.consumptionConfirmationCount}?kitchen_id=$kitchenId",
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["pending_count"].toString();
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
