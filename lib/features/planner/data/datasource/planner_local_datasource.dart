import 'dart:convert';
import 'package:foodkitchen/features/planner/data/models/meal_type_model.dart';
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
      final currentList = await getWeeklyPlans();
      final alreadyExists = currentList.any(
        (plan) => plan.formatedDateString == newPlan.formatedDateString,
      );

      if (alreadyExists) {
        return "Already added for this date";
      }
      currentList.add(newPlan);

      await saveThings(currentList);
      return "Added to your weekly plan";
    } catch (e) {
      return "Something went wrong, Please try again later.";
    }
  }

  @override
  Future<List<MealTypeModel>> getWeeklyPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList('weekly_plan') ?? [];

    return jsonList
        .map((jsonString) => MealTypeModel.fromJson(jsonDecode(jsonString)))
        .toList();
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
