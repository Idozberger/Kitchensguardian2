import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PlannerLocalDatasource {
  Future<String> addToWeeklyPlan({required MealTypeModel newPlan});
  Future<List<MealTypeModel>> getWeeklyPlans();
  Future<String> deleteWeeklyPlan({required String selectedDate});
}

class PlannerLocalDatasourceImpl implements PlannerLocalDatasource {
  final SharedPreferences sharedPreferences;
  PlannerLocalDatasourceImpl(this.sharedPreferences);
  @override
  Future<String> addToWeeklyPlan({required MealTypeModel newPlan}) async {
    try {
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      final currentList = await getWeeklyPlans();

      String? getEndDateString = sharedPreferences.getString("end-date");
      debugPrint("Stored end-date: $getEndDateString");

      if (getEndDateString != null) {
        DateTime endDateTime = parseDate(getEndDateString);
        final endDateInDaysMonthYear = DateTime(
          endDateTime.year,
          endDateTime.month,
          endDateTime.day,
        );
        if (endDateInDaysMonthYear.isBefore(today)) {
          debugPrint("End date reached! Resetting start and end dates...");
          sharedPreferences.setString("start-date", formatDate(today));

          if (AppConstants.entitlementIsActive == false) {
            final newEndDate = formatDate(
              DateTime.now().add(Duration(days: 2)),
            );
            sharedPreferences.setString("end-date", newEndDate);
            debugPrint("Free user — new end-date set to: $newEndDate");
          } else {
            final newEndDate = formatDate(
              DateTime.now().add(Duration(days: 6)),
            );
            sharedPreferences.setString("end-date", newEndDate);
            debugPrint("Premium user — new end-date set to: $newEndDate");
          }
        } else {
          debugPrint("End date not reached yet.");
        }
      }

      if (currentList.isEmpty) {
        sharedPreferences.setString("start-date", formatDate(today));

        if (AppConstants.entitlementIsActive == false) {
          final newEndDate = formatDate(DateTime.now().add(Duration(days: 2)));
          sharedPreferences.setString("end-date", newEndDate);
          debugPrint("Free user — new end-date set to: $newEndDate");
        } else {
          final newEndDate = formatDate(DateTime.now().add(Duration(days: 6)));
          sharedPreferences.setString("end-date", newEndDate);
          debugPrint("Premium user — new end-date set to: $newEndDate");
        }
      }

      final alreadyExists = currentList.any(
        (plan) => plan.formatedDateString == newPlan.formatedDateString,
      );

      if (alreadyExists) {
        return "Already added for this date";
      }

      currentList.add(newPlan);

      await saveThings(currentList);
      debugPrint(
        "Weekly plan list saved successfully. Total plans: ${currentList.length}",
      );

      return "Added to your weekly plan";
    } catch (e, stackTrace) {
      debugPrint("❌ Error adding to weekly plan: $e");
      debugPrint("🪜 Stack trace: $stackTrace");
      return "Something went wrong, Please try again later.";
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
    } catch (e, stack) {
      debugPrint("Error in getWeeklyPlans(): $e");

      return [];
    }
  }

  Future<void> saveThings(List<MealTypeModel> list) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> jsonList = list
        .map((item) => jsonEncode(item.toJson()))
        .toList();

    await prefs.setStringList('weekly_plan', jsonList);
  }

  @override
  Future<String> deleteWeeklyPlan({required String selectedDate}) async {
    try {
      final currentList = await getWeeklyPlans();

      currentList.removeWhere(
        (plan) => plan.formatedDateString == selectedDate,
      );

      await saveThings(currentList);

      return "Plan for $selectedDate deleted successfully.";
    } catch (e) {
      return "Failed to delete plan. Please try again.";
    }
  }
}
