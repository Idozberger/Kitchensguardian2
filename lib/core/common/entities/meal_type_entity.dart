import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';

class MealTypeEntity {
  final String id;
  final String formatedDateString;
  final String mealType;
  final String title;
  final String calories;
  final String cookingTime;
  final String recipeShortSummary;
  final List<String> cookingSteps;
  final List<Map<String, dynamic>> doneSteps;
  final List<IngredientEntity> ingredients;
  final bool missingItems;
  final bool available;

  MealTypeEntity({
    required this.id,
    required this.title,
    required this.calories,
    required this.cookingTime,
    required this.recipeShortSummary,
    required this.cookingSteps,
    required this.ingredients,
    required this.missingItems,
    required this.available,
    required this.mealType,
    required this.formatedDateString,
    this.doneSteps = const [],
  });
}
