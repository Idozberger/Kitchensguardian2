import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
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
  Future<List<MealTypeModel>> getWeeklyPlans();
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
      log('✅ Parsed Items: ${response.data}');
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

        log('✅ Parsed Items: $parsedItems');

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
  Future<List<MealTypeModel>> getWeeklyPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<String> jsonList = prefs.getStringList('weekly_plan') ?? [];

      List<MealTypeModel> allPlans = jsonList
          .map((jsonString) => MealTypeModel.fromJson(jsonDecode(jsonString)))
          .toList();

      List<MealTypeModel> filteredPlans = [];

      String? startDate = sharedPreferences.getString("start-date");
      debugPrint("Start date from SharedPreferences: $startDate");

      for (var i = 0; i < allPlans.length; i++) {
        final plan = allPlans[i];
        final parsedDate = parseDate(plan.formatedDateString);
        final planDate = DateTime(
          parsedDate.year,
          parsedDate.month,
          parsedDate.day,
        );

        if (startDate != null) {
          DateTime startDateTime = parseDate(startDate);
          final startDateTimePlanString = DateTime(
            startDateTime.year,
            startDateTime.month,
            startDateTime.day,
          ).subtract(Duration(days: 1));

          if (planDate.isAfter(startDateTimePlanString)) {
            filteredPlans.add(plan);
          } else {
            debugPrint("Skipped plan #$i — older than start date");
          }
        } else {
          debugPrint("No start-date found, skipping filtering logic");
        }
      }

      debugPrint("Filtered plans count: ${filteredPlans.length}");
      return filteredPlans;
    } catch (e) {
      debugPrint("Error in getWeeklyPlans(): $e");

      return [];
    }
  }

  DateTime parseDate(String formattedDateString) {
    return DateFormat("dd/MM/yyyy").parse(formattedDateString);
  }
}
