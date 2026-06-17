import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

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
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        final Object? message = data['error'];
        throw apiExceptionFrom(message);
      }

      final Map<String, dynamic> root = jsonObjectFromResponseData(
        response.data,
      );
      final Object? conf = root['confirmations'];
      if (conf is! List) return [];
      return conf.map(jsonObjectFromResponseData).toList();
    } on DioException catch (e) {
      throw await dio.handleError(e);
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
      devLog("dio error: $response ${response.statusCode}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        final Object? message = data['error'];
        throw apiExceptionFrom(message);
      }
      final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
      return readJsonString(ok, 'message');
    } on DioException catch (e) {
      throw await dio.handleError(e);
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
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        final Object? message = data['error'];
        throw apiExceptionFrom(message);
      }
      final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
      final Object? pc = ok['pending_count'];
      return pc?.toString() ?? '0';
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }
}
