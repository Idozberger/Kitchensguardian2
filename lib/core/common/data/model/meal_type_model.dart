import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';

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
    required super.missingIngredients,
    required super.thumbnail,
  });

  factory MealTypeModel.fromJson(Map<String, dynamic> json) {
    Uint8List? thumbnailBytes;
    //TODO AFTER APIS to remove this code
    final thumbnail = json["thumbnail"];
    if (thumbnail != null) {
      if (thumbnail is String) {
        try {
          thumbnailBytes = base64Decode(thumbnail);
        } catch (e) {
          debugPrint("⚠️ Error decoding thumbnail base64: $e");
        }
      } else if (thumbnail is List) {
        thumbnailBytes = Uint8List.fromList(thumbnail.cast<int>());
      } else if (thumbnail is Uint8List) {
        thumbnailBytes = thumbnail;
      }
    }
    return MealTypeModel(
      id: json["_id"],
      title: json["title"],
      calories: json["calories"],
      cookingTime: json["cooking_time"],
      recipeShortSummary: json["recipe_short_summary"],
      cookingSteps: List<String>.from(json["cooking_steps"] ?? []),
      missingItems: json["missing_items"] ?? false,
      thumbnail: thumbnailBytes,
      ingredients: (json["ingredients"] as List)
          .map(
            (e) => IngredientEntity(
              name: e["name"],
              amount: e["amount"].toString(),
              unit: e["unit"],
            ),
          )
          .toList(),
      missingIngredients:
          (json["missing_items_list"] != null &&
              json["missing_items_list"] is List)
          ? (json["missing_items_list"] as List)
                .map(
                  (e) => IngredientEntity(
                    name: e["name"] ?? "",
                    amount: e["amount"].toString(),
                    unit: e["unit"] ?? "",
                  ),
                )
                .toList()
          : [],

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
      "thumbnail": thumbnail,
      "missing_items_list": missingIngredients,
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
    List<IngredientEntity>? missingIngredients,
    bool? missingItems,
    bool? available,
    String? mealType,
    String? formatedDateString,
    Uint8List? thumbnail,
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
      missingIngredients: missingIngredients ?? this.missingIngredients,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}
