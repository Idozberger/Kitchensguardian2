import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/common/domain/entities/expiring_item_entity.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';

class RecipeModel extends RecipeEntity {
  RecipeModel({
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
    required super.expiringItems,
    required super.expiringItemsCount,
    required super.expiringItemsUsed,
  });

  static Uint8List? _parseThumbnail(Object? value) {
    if (value == null) return null;

    try {
      if (value is String) return base64Decode(value);
      if (value is List) return Uint8List.fromList(value.cast<int>());
      if (value is Uint8List) return value.isEmpty ? null : value;
    } catch (e) {
      devPrint("⚠️ Thumbnail decode failed: $e");
    }

    return null;
  }

  static List<IngredientEntity> _parseIngredients(Object? list) {
    if (list is! List) return [];
    return list.map((Object? e) {
      final Map<String, dynamic> row = jsonObjectFromResponseData(e);
      return IngredientEntity(
        name: readJsonString(row, 'name'),
        amount: readJsonString(row, 'amount'),
        unit: readJsonString(row, 'unit'),
      );
    }).toList();
  }

  static List<ExpiringItemEntity> _safeList(Object? list) {
    if (list is! List) return [];

    return list.map((Object? e) {
      final Map<String, dynamic> field = jsonObjectFromResponseData(e);

      return ExpiringItemEntity(
        itemName: readJsonString(field, 'name'),
        expiryStatus: readJsonString(field, 'expiry_status'),
        itemId: readJsonString(field, 'item_id'),
        quantity: readJsonDouble(field, 'quantity'),
        unit: readJsonString(field, 'unit'),
      );
    }).toList();
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: readJsonString(json, '_id'),
      mealplanId: readJsonString(json, 'meal_plan_id'),
      title: readJsonString(json, 'title'),
      calories: readJsonString(json, 'calories'),
      cookingTime: readJsonString(json, 'cooking_time'),
      recipeShortSummary: readJsonString(json, 'recipe_short_summary'),
      cookingSteps: readJsonStringList(json, 'cooking_steps'),
      missingItems: readJsonBool(json, 'missing_items'),
      available: readJsonBool(json, 'available'),
      mealType: readJsonString(json, 'meal_type'),
      formatedDateString: readJsonString(json, 'selected_date'),
      recipeId: readJsonString(json, 'recipe_id'),
      kitchenId: readJsonString(json, 'kitchen_id'),
      date: readJsonString(json, 'date'),
      createdAt: readJsonString(json, 'createdAt'),
      updatedAt: readJsonString(json, 'updatedAt'),
      createdBy: readJsonString(json, 'createdBy'),
      isCompleted: readJsonBool(json, 'is_completed'),
      notes: readJsonString(json, 'notes'),

      /// Parsed fields
      thumbnail: _parseThumbnail(json['thumbnail']),
      ingredients: _parseIngredients(json['ingredients']),
      missingIngredients: _parseIngredients(json['missing_items_list']),

      /// NEW FIELDS
      expiringItems: _safeList(json['expiring_items']),
      expiringItemsCount: readJsonInt(json, 'expiring_items_count'),
      expiringItemsUsed: readJsonStringList(json, 'expiring_items_used'),
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
      "meal_type": mealType,
      "selected_date": formatedDateString,
      "thumbnail": thumbnail,
      "missing_items_list": missingIngredients,
      "recipe_id": recipeId,
      "kitchenId": kitchenId,
      "date": date,
      "createdAt": createdAt,
      "updatedAt": updatedAt,
      "createdBy": createdBy,
      "isCompleted": isCompleted,
      "notes": notes,

      "expiring_items": expiringItems,
      "expiring_items_count": expiringItemsCount,
      "expiring_items_used": expiringItemsUsed,
    };
  }

  RecipeModel copyWith({
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
    List<ExpiringItemEntity>? expiringItems,
    int? expiringItemsCount,
    List<String>? expiringItemsUsed,
  }) {
    return RecipeModel(
      id: id ?? this.id,
      mealplanId: mealPlanId ?? mealplanId,
      title: title ?? this.title,
      calories: calories ?? this.calories,
      cookingTime: cookingTime ?? this.cookingTime,
      recipeShortSummary: recipeShortSummary ?? this.recipeShortSummary,
      cookingSteps: cookingSteps ?? this.cookingSteps,
      ingredients: ingredients ?? this.ingredients,
      missingIngredients: missingIngredients ?? this.missingIngredients,
      missingItems: missingItems ?? this.missingItems,
      available: available ?? this.available,
      mealType: mealType ?? this.mealType,
      formatedDateString: formatedDateString ?? this.formatedDateString,
      thumbnail: thumbnail ?? this.thumbnail,
      recipeId: recipeId ?? this.recipeId,
      kitchenId: kitchenId ?? this.kitchenId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      isCompleted: isCompleted ?? this.isCompleted,
      notes: notes ?? this.notes,

      expiringItems: expiringItems ?? this.expiringItems,
      expiringItemsCount: expiringItemsCount ?? this.expiringItemsCount,
      expiringItemsUsed: expiringItemsUsed ?? this.expiringItemsUsed,
    );
  }
}
