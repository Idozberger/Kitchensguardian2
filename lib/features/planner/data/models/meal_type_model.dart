import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';

import '../../domain/entities/meal_type_entity.dart';

class MealTypeModel extends MealTypeEntity {
  MealTypeModel({
    required super.id,
    required super.title,
    required super.calories,
    required super.cookingTime,
    required super.recipeShortSummary,
    required super.cookingSteps,
    required super.ingredients,
    required super.missingItems,
  });

  factory MealTypeModel.fromJson(Map<String, dynamic> json) {
    return MealTypeModel(
      id: json["_id"],
      title: json["title"],
      calories: json["calories"],
      cookingTime: json["cooking_time"],
      recipeShortSummary: json["recipe_short_summary"],
      cookingSteps: List<String>.from(json["cooking_steps"] ?? []),
      missingItems: json["missing_items"] ?? false,
      ingredients: (json["ingredients"] as List)
          .map(
            (e) => IngredientEntity(
              name: e["name"],
              amount: e["amount"],
              unit: e["unit"],
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "title": title,
      "calories": calories,
      "cooking_time": cookingTime,
      "recipe_short_summary": recipeShortSummary,
      "cooking_steps": cookingSteps,
      "missing_items": missingItems,
      "ingredients": ingredients
          .map((e) => {"name": e.name, "amount": e.amount, "unit": e.unit})
          .toList(),
    };
  }
}
