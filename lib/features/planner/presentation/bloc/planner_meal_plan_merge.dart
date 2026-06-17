import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/features/planner/data/models/merged_meal_plan_model.dart';
import 'package:foodkitchen/features/planner/domain/entities/merged_meal_type_entity.dart';

List<MergedRecipePlanEntity> mergeMealPlansByDate(List<RecipeEntity> meals) {
  for (var element in meals) {
    devLog("ERROR: ${element.title}");
  }
  List<MergedRecipePlanEntity> grouped = [];

  for (var i = 0; i < meals.length; i++) {
    final currentMeal = meals[i];

    final existingIndex = grouped.indexWhere((element) {
      devLog("EELELLE ${element.date} == ${currentMeal.date}");
      return element.date == currentMeal.date;
    });

    if (existingIndex != -1) {
      MergedMealPlanModel existing = MergedMealPlanModel.fromEntity(
        grouped[existingIndex],
      );

      grouped[existingIndex] = existing.copyWith(
        date: currentMeal.date,
        breakfast: currentMeal.mealType.toLowerCase() == "breakfast"
            ? currentMeal
            : existing.breakfast,
        lunch: currentMeal.mealType.toLowerCase() == "lunch"
            ? currentMeal
            : existing.lunch,
        dinner: currentMeal.mealType.toLowerCase() == "dinner"
            ? currentMeal
            : existing.dinner,
      );
    } else {
      devLog(
        "No existing meal plan found for date: ${currentMeal.date}, adding new plan",
      );

      grouped.add(
        MergedRecipePlanEntity(
          date: currentMeal.date,
          breakfast: currentMeal.mealType.toLowerCase() == "breakfast"
              ? currentMeal
              : null,
          lunch: currentMeal.mealType.toLowerCase() == "lunch"
              ? currentMeal
              : null,
          dinner: currentMeal.mealType.toLowerCase() == "dinner"
              ? currentMeal
              : null,
        ),
      );
    }
  }

  devLog("Grouped meal plans: $grouped");

  return grouped;
}
