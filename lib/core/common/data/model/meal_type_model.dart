import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';

class MealTypeModel extends MealTypeEntity {
  MealTypeModel({
    required super.id,
    required super.mealplanId,
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
    required super.recipeId,
    required super.kitchenId,
    required super.date,
    required super.createdAt,
    required super.updatedAt,
    required super.createdBy,
    required super.isCompleted,
    required super.notes,
  });
  factory MealTypeModel.fromJson(Map<String, dynamic> json) {
    Uint8List? thumbnailBytes;

    final thumbnail = json.containsKey("thumbnail") ? json["thumbnail"] : null;
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
      id: json.containsKey("_id") ? json["_id"] ?? '' : '',
      mealplanId: json.containsKey("meal_plan_id")
          ? json["meal_plan_id"] ?? ''
          : '',
      title: json.containsKey("title") ? json["title"] ?? '' : '',
      calories: json.containsKey("calories") ? json["calories"] ?? '' : '',
      cookingTime: json.containsKey("cooking_time")
          ? json["cooking_time"] ?? ''
          : '',
      recipeShortSummary: json.containsKey("recipe_short_summary")
          ? json["recipe_short_summary"] ?? ''
          : '',
      cookingSteps: json.containsKey("cooking_steps")
          ? List<String>.from(json["cooking_steps"] ?? [])
          : [],
      missingItems: json.containsKey("missing_items")
          ? json["missing_items"] ?? false
          : false,
      thumbnail: thumbnailBytes,
      ingredients: json.containsKey("ingredients")
          ? (json["ingredients"] as List)
                .map(
                  (e) => IngredientEntity(
                    name: e["name"] ?? '',
                    amount: e["amount"]?.toString() ?? '',
                    unit: e["unit"] ?? '',
                  ),
                )
                .toList()
          : [],
      missingIngredients: json.containsKey("missing_items_list")
          ? (json["missing_items_list"] != null &&
                    json["missing_items_list"] is List)
                ? (json["missing_items_list"] as List)
                      .map(
                        (e) => IngredientEntity(
                          name: e["name"] ?? '',
                          amount: e["amount"]?.toString() ?? '',
                          unit: e["unit"] ?? '',
                        ),
                      )
                      .toList()
                : []
          : [],
      available: json.containsKey("available")
          ? json["available"] ?? false
          : false,
      mealType: json.containsKey("meal_type") ? json["meal_type"] ?? '' : '',
      formatedDateString: json.containsKey("selected_date")
          ? json["selected_date"] ?? ''
          : '',
      recipeId: json.containsKey("recipeId") ? json["recipeId"] ?? '' : '',
      kitchenId: json.containsKey("kitchenId") ? json["kitchenId"] ?? '' : '',
      date: json.containsKey("date") ? json["date"] ?? '' : '',
      createdAt: json.containsKey("createdAt") ? json["createdAt"] ?? '' : '',
      updatedAt: json.containsKey("updatedAt") ? json["updatedAt"] ?? '' : '',
      createdBy: json.containsKey("createdBy") ? json["createdBy"] ?? '' : '',
      isCompleted: json.containsKey("isCompleted")
          ? json["isCompleted"] ?? false
          : false,
      notes: json.containsKey("notes") ? json["notes"] ?? '' : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "meal_plan_id": mealplanId,
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
      "recipeId": recipeId,
      "kitchenId": kitchenId,
      "date": date,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "createdBy": createdBy,
      "isCompleted": isCompleted,
      "notes": notes,
    };
  }

  MealTypeModel copyWith({
    String? id,
    String? mealPlanId,
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
    String? recipeId,
    String? kitchenId,
    String? date,
    String? createdAt,
    String? updatedAt,
    String? createdBy,
    bool? isCompleted,
    String? notes,
  }) {
    return MealTypeModel(
      id: id ?? this.id,
      mealplanId: mealplanId,
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
      recipeId: recipeId ?? this.recipeId,
      kitchenId: kitchenId ?? this.kitchenId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,
    );
  }
}
