import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/data/model/recipe_model.dart';
import 'package:foodkitchen/core/common/entitlement/user_entitlement_snapshot.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class PlannerLocalDatasource {
  Future<String> addToWeeklyPlan({required RecipeModel newPlan});
  Future<List<RecipeModel>> getWeeklyPlans();
  Future<String> deleteWeeklyPlan({required String selectedDate});
  Future<List<RecipeModel>> deleteMealTypeFromWeeklyPlan({
    required String selectedDate,
    required String mealType,
  });
}

class PlannerLocalDatasourceImpl implements PlannerLocalDatasource {
  PlannerLocalDatasourceImpl(
    this.sharedPreferences,
    this._entitlementSnapshot,
  );

  final SharedPreferences sharedPreferences;
  final UserEntitlementSnapshot _entitlementSnapshot;
  @override
  Future<String> addToWeeklyPlan({required RecipeModel newPlan}) async {
    try {
      final today = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      final currentList = await getWeeklyPlans();

      String? getEndDateString = sharedPreferences.getString("end-date");
      devPrint("Stored end-date: $getEndDateString");
      // If the user opens the app at 11:59 PM and tries to add a new plan,
      // this function will trigger to reset the plan dates accordingly
      if (getEndDateString != null) {
        DateTime endDateTime = parseDate(getEndDateString);
        final endDateInDaysMonthYear = DateTime(
          endDateTime.year,
          endDateTime.month,
          endDateTime.day,
        );
        if (endDateInDaysMonthYear.isBefore(today)) {
          devPrint("End date reached! Resetting start and end dates...");
          sharedPreferences.setString("start-date", formatDate(today));

          if (!_entitlementSnapshot.hasPremiumAccess) {
            final newEndDate = formatDate(
              DateTime.now().add(Duration(days: 2)),
            );
            sharedPreferences.setString("end-date", newEndDate);
            devPrint("Free user — new end-date set to: $newEndDate");
          } else {
            final newEndDate = formatDate(
              DateTime.now().add(Duration(days: 6)),
            );
            sharedPreferences.setString("end-date", newEndDate);
            devPrint("Premium user — new end-date set to: $newEndDate");
          }
        } else {
          devPrint("End date not reached yet.");
        }
      }

      if (currentList.isEmpty) {
        sharedPreferences.setString("start-date", formatDate(today));

        if (!_entitlementSnapshot.hasPremiumAccess) {
          final newEndDate = formatDate(DateTime.now().add(Duration(days: 2)));
          sharedPreferences.setString("end-date", newEndDate);
          devPrint("Free user — new end-date set to: $newEndDate");
        } else {
          final newEndDate = formatDate(DateTime.now().add(Duration(days: 6)));
          sharedPreferences.setString("end-date", newEndDate);
          devPrint("Premium user — new end-date set to: $newEndDate");
        }
      }

      final matchingPlans = currentList
          .where(
            (plan) => plan.formatedDateString == newPlan.formatedDateString,
          )
          .toList();

      final alreadyExists = matchingPlans.any(
        (plan) => plan.mealType.toLowerCase() == newPlan.mealType.toLowerCase(),
      );

      if (alreadyExists) {
        return "${newPlan.mealType} meal already added for this date";
      }

      devPrint(
        "Adding new meal type '${newPlan.mealType}' for ${newPlan.formatedDateString}",
      );

      currentList.add(newPlan);

      if (matchingPlans.isEmpty) {
        devPrint("Added new plan for ${newPlan.formatedDateString}");
      }

      await saveThings(currentList);
      devPrint(
        "Weekly plan list saved successfully. Total plans: ${currentList.length}",
      );

      return "Added ${newPlan.mealType} meal successfully";
    } catch (e, stackTrace) {
      devPrint("❌ Error adding to weekly plan: $e");
      devPrint("🪜 Stack trace: $stackTrace");
      return "Something went wrong, Please try again later.";
    }
  }

  @override
  Future<List<RecipeModel>> getWeeklyPlans() async {
    try {
      final List<String> jsonList =
          sharedPreferences.getStringList('weekly_plan') ?? [];

      List<RecipeModel> allPlans = jsonList
          .map(
            (String jsonString) => RecipeModel.fromJson(
              jsonObjectFromResponseData(jsonDecode(jsonString)),
            ),
          )
          .toList();

      List<RecipeModel> filteredPlans = [];

      String? startDate = sharedPreferences.getString("start-date");
      devPrint("Start date from SharedPreferences: $startDate");

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
            devPrint("Skipped plan #$i — older than start date");
          }
        } else {
          devPrint("No start-date found, skipping filtering logic");
        }
      }

      devPrint("Filtered plans count: ${filteredPlans.length}");
      return filteredPlans;
    } catch (e) {
      devPrint("Error in getWeeklyPlans(): $e");

      return [];
    }
  }

  Future<void> saveThings(List<RecipeModel> list) async {
    try {
      devPrint("Saving ${list.length} meal plans to SharedPreferences...");

      if (list.isEmpty) {
        devPrint("The list of meal plans is empty.");
      }

      final List<String> jsonList = list.map((item) {
        final jsonString = jsonEncode({
          "_id": item.id,
          "title": item.title,
          "calories": item.calories,
          "cooking_time": item.cookingTime,
          "recipe_short_summary": item.recipeShortSummary,
          "cooking_steps": item.cookingSteps,
          "missing_items": item.missingItems,
          "ingredients": item.ingredients
              .map((e) => {"name": e.name, "amount": e.amount, "unit": e.unit})
              .toList(),
          "available": item.available,
          "selected_meal_type": item.mealType,
          "selected_date": item.formatedDateString,
          "thumbnail": (item.thumbnail != null && item.thumbnail!.isNotEmpty)
              ? base64Encode(item.thumbnail!)
              : "",
          "missing_items_list": item.missingIngredients,
        });
        devPrint("Serialized meal plan to JSON: $jsonString");
        return jsonString;
      }).toList();

      devPrint("Serialized JSON list to save: $jsonList");

      bool success = await sharedPreferences.setStringList(
        'weekly_plan',
        jsonList,
      );

      if (success) {
        devPrint(
          "Successfully saved ${jsonList.length} meal plans to SharedPreferences.",
        );
      } else {
        devPrint("Failed to save meal plans to SharedPreferences.");
      }
    } catch (e, stack) {
      devPrint("Error in saveThings(): $e");
      devPrint("Stack trace: $stack");
    }
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

  @override
  Future<List<RecipeModel>> deleteMealTypeFromWeeklyPlan({
    required String selectedDate,
    required String mealType,
  }) async {
    try {
      final currentList = await getWeeklyPlans();

      final index = currentList.indexWhere(
        (plan) =>
            plan.formatedDateString == selectedDate &&
            plan.mealType.toLowerCase() == mealType.toLowerCase(),
      );

      if (index != -1) {
        currentList.removeAt(index);
        await saveThings(currentList);
        devPrint("Deleted $mealType for $selectedDate successfully.");
      } else {
        devPrint("No matching plan found for $mealType on $selectedDate.");
      }

      return currentList;
    } catch (e, stack) {
      devPrint("Error in deleteMealTypeFromWeeklyPlan(): $e");
      debugPrintStack(stackTrace: stack);
      return [];
    }
  }
}
