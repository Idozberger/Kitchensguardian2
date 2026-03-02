import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

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
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final data = response.data["members"];

      if (data is List) {
        debugPrint("Kitchen members: ${data.map((member) => member)}");
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception("Invalid data");
      }
    } on DioException catch (e) {
      throw dio.handleError(e);
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
  Future<List<Map<String, dynamic>>> getConsumptionConfirmationPending({
    required String kitchenId,
  }) async {
    try {
      log("comsumption confirmation pending: ");
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
      log("comsumption confirmation pending: ${response.data}");
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
      log("confirmatin id: $confirmationId");
      final response = await dio.post(
        AppConstants.consumptionConfirmationRespond,
        data: {
          "confirmation_id": confirmationId,
          "response": responseText,
          "actual_quantity_remaining": actualQuantityRemaining,
        },
      );
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

  @override
  Future<List<Map<String, dynamic>>> getRecipeDetails({
    required String recipeId,
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get("${AppConstants.recipeById}$recipeId");

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        throw data["error"] ?? "Something went wrong";
      }

      if (response.data is Map<String, dynamic>) {
        final recipe = Map<String, dynamic>.from(response.data);

        final thumbnailBase64 = recipe["thumbnail"];
        if (thumbnailBase64 is String && thumbnailBase64.isNotEmpty) {
          try {
            recipe["thumbnail"] = base64Decode(
              thumbnailBase64.contains(",")
                  ? thumbnailBase64.split(",").last.trim()
                  : thumbnailBase64.trim(),
            );
          } catch (_) {
            recipe["thumbnail"] = Uint8List(0);
          }
        }

        return [recipe];
      }

      throw Exception("Invalid data format for recipe details");
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }
}
