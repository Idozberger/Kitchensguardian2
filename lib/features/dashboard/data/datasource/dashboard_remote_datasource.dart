import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

abstract interface class DashboardRemoteDatasource {
  Future<List<Map<String, dynamic>>> getRecipeDetails({
    required String kitchenId,
    required String recipeId,
  });
  Future<List<Map<String, dynamic>>> getKitchenMembers({
    required String kitchenId,
  });
  Future<String> makeCohost({
    required String kitchenId,
    required String memberId,
  });
  Future<String> kickMember({
    required String kitchenId,
    required String memberId,
  });
  Future<String> demoteCohost({
    required String kitchenId,
    required String memberId,
  });
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

class DashboardRemoteDatasourceImpl implements DashboardRemoteDatasource {
  final DioHelper dio;
  DashboardRemoteDatasourceImpl(this.dio);
  @override
  Future<List<Map<String, dynamic>>> getKitchenMembers({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.getMembers}?kitchen_id=$kitchenId",
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
      final Object? membersRaw = root['members'];

      if (membersRaw is List) {
        devPrint("Kitchen members: ${membersRaw.map((member) => member)}");
        return membersRaw.map(jsonObjectFromResponseData).toList();
      } else {
        throw Exception("Invalid data");
      }
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  @override
  Future<String> kickMember({
    required String kitchenId,
    required String memberId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.kickMember,
        data: {"kitchen_id": kitchenId, "member_id": memberId},
      );
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
  Future<String> makeCohost({
    required String kitchenId,
    required String memberId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.makeCohost,
        data: {"kitchen_id": kitchenId, "member_id": memberId},
      );
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
  Future<String> demoteCohost({
    required String kitchenId,
    required String memberId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.demoteCohost,
        data: {"kitchen_id": kitchenId, "member_id": memberId},
      );
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
  Future<List<Map<String, dynamic>>> getConsumptionConfirmationPending({
    required String kitchenId,
  }) async {
    try {
      devLog("comsumption confirmation pending: ");
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
      devLog("comsumption confirmation pending: ${response.data}");
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
      devLog("confirmatin id: $confirmationId");
      final response = await dio.post(
        AppConstants.consumptionConfirmationRespond,
        data: {
          "confirmation_id": confirmationId,
          "response": responseText,
          "actual_quantity_remaining": actualQuantityRemaining,
        },
      );
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

  @override
  Future<List<Map<String, dynamic>>> getRecipeDetails({
    required String recipeId,
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get("${AppConstants.recipeById}$recipeId");

      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );
        throw apiExceptionFrom(data['error'] ?? 'Something went wrong');
      }

      final Map<String, dynamic> recipe = Map<String, dynamic>.from(
        jsonObjectFromResponseData(response.data),
      );

      final Object? thumbnailBase64 = recipe['thumbnail'];
      if (thumbnailBase64 is String && thumbnailBase64.isNotEmpty) {
        try {
          recipe['thumbnail'] = base64Decode(
            thumbnailBase64.contains(",")
                ? thumbnailBase64.split(',').last.trim()
                : thumbnailBase64.trim(),
          );
        } catch (_) {
          recipe['thumbnail'] = null;
        }
      }

      return [recipe];
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }
}
