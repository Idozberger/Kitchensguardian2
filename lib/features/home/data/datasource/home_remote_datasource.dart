import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class HomeRemoteDataSource {
  Future<Map<String, dynamic>> createKitchen({required String kitchenName});
  Future<String> joinKitchen({required String invitationCode});
  Future<Map<String, List<Map<String, dynamic>>>> getPantriesItems({
    required String kitchenId,
  });
  Future<List<Map<String, dynamic>>> getWeeklyPlans({
    required String kitchenId,
  });
  Future<Map<String, dynamic>> getRecipeSuggestion({required String kitchenId});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SharedPreferences sharedPreferences;
  final DioHelper dio;
  HomeRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });
  @override
  Future<Map<String, dynamic>> createKitchen({
    required String kitchenName,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.createKitchen,
        data: {"kitchen_name": kitchenName},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      sharedPreferences.setString("kitchen_id", response.data["kitchen_id"]);
      sharedPreferences.setString(
        "invitation_code",
        response.data["invitation_code"],
      );

      return response.data;
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> joinKitchen({required String invitationCode}) async {
    try {
      final response = await dio.post(
        AppConstants.joinKitchen,
        data: {"invitation_code": invitationCode},
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
  Future<Map<String, List<Map<String, dynamic>>>> getPantriesItems({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.getPantryItems}?kitchen_id=$kitchenId",
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final items = response.data["items"];

      if (items is List) {
        final parsedItems = items
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

        return {"items": parsedItems, "pantry_types": []};
      } else {
        throw Exception("Invalid data format");
      }
    } on DioException catch (e) {
      throw dio.handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWeeklyPlans({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.listAllMealPlans}?kitchen_id=$kitchenId",
      );

      final raw = response.data;

      if (raw is String && raw.trim().startsWith("<!doctype html")) {
        log("⚠ HTML returned instead of JSON. Returning empty list.");
        return [];
      }

      final data = raw["meal_plans"];

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      if (data is List) {
        return data.map<Map<String, dynamic>>((e) {
          final recipe = Map<String, dynamic>.from(e);

          final thumbnailBase64 = recipe["thumbnail"];

          if (thumbnailBase64 is String && thumbnailBase64.isNotEmpty) {
            try {
              recipe["thumbnail"] = base64Decode(
                thumbnailBase64.contains(",")
                    ? thumbnailBase64.split(",").last.trim()
                    : thumbnailBase64.trim(),
              );
            } catch (e) {
              recipe["thumbnail"] = Uint8List(0);
            }
          }
          return recipe;
        }).toList();
      } else {
        throw Exception("Invalid data format for favourite_recipes");
      }
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  DateTime parseDate(String formattedDateString) {
    return DateFormat("dd/MM/yyyy").parse(formattedDateString);
  }

  @override
  Future<Map<String, dynamic>> getRecipeSuggestion({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.suggestRecipe}?kitchen_id=$kitchenId",
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        debugPrint("Suggested Recipe: $message");
        throw "Server error, please try again";
      }
      return response.data;
    } on DioException catch (e) {
      throw dio.handleError(e);
    } catch (e) {
      rethrow;
    }
  }
}
