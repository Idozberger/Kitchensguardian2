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
    required super.available,
    required super.mealType,
    required super.formatedDateString,
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
      available:
          (json.containsKey("available") ? json["available"] : false) ?? false,
      mealType:
          (json.containsKey("selected_meal_type")
              ? json["selected_meal_type"]
              : "") ??
          "",
      formatedDateString:
          (json.containsKey("selected_date") ? json["selected_date"] : "") ??
          "",
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
      "available": available,
      "selected_meal_type": mealType,
      "selected_date": formatedDateString,
    };
  }

  MealTypeModel copyWith({
    String? id,
    String? title,
    String? calories,
    String? cookingTime,
    String? recipeShortSummary,
    List<String>? cookingSteps,
    List<IngredientEntity>? ingredients,
    bool? missingItems,
    bool? available,
    String? mealType,
    String? formatedDateString,
  }) {
    return MealTypeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      calories: calories ?? this.calories,
      cookingTime: cookingTime ?? this.cookingTime,
      recipeShortSummary: recipeShortSummary ?? this.recipeShortSummary,
      cookingSteps: cookingSteps ?? this.cookingSteps,
      ingredients: ingredients ?? this.ingredients,
      missingItems: missingItems ?? this.missingItems,
      available: available ?? this.available,
      mealType: mealType ?? this.mealType,
      formatedDateString: formatedDateString ?? this.formatedDateString,
    );
  }
}
