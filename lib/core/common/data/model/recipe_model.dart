import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/common/domain/entities/expiring_item_entity.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
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

  static Uint8List? _parseThumbnail(dynamic value) {
    if (value == null) return null;

    try {
      if (value is String) return base64Decode(value);
      if (value is List) return Uint8List.fromList(value.cast<int>());
      if (value is Uint8List) return value;
    } catch (e) {
      debugPrint("⚠️ Thumbnail decode failed: $e");
    }

    return null;
  }

  static List<IngredientEntity> _parseIngredients(dynamic list) {
    if (list is! List) return [];
    return list.map((e) {
      return IngredientEntity(
        name: e["name"] ?? "",
        amount: e["amount"]?.toString() ?? "",
        unit: e["unit"] ?? "",
      );
    }).toList();
  }

  static List<ExpiringItemEntity> _safeList(dynamic list) {
    if (list is! List) return [];

    return list.map((e) {
      final field = Map<String, dynamic>.from(e);

      return ExpiringItemEntity(
        itemName: field["name"],
        expiryStatus: field["expiry_status"],
        itemId: field["item_id"],
        quantity: field["quantity"],
        unit: field["unit"],
      );
    }).toList();
  }

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json["_id"] ?? "",
      mealplanId: json["meal_plan_id"] ?? "",
      title: json["title"] ?? "",
      calories: json["calories"] ?? "",
      cookingTime: json["cooking_time"] ?? "",
      recipeShortSummary: json["recipe_short_summary"] ?? "",
      cookingSteps: List<String>.from(json["cooking_steps"] ?? []),
      missingItems: json["missing_items"] ?? false,
      available: json["available"] ?? false,
      mealType: json["meal_type"] ?? "",
      formatedDateString: json["selected_date"] ?? "",
      recipeId: json["recipeId"] ?? "",
      kitchenId: json["kitchenId"] ?? "",
      date: json["date"] ?? "",
      createdAt: json["createdAt"] ?? "",
      updatedAt: json["updatedAt"] ?? "",
      createdBy: json["createdBy"] ?? "",
      isCompleted: json["isCompleted"] ?? false,
      notes: json["notes"] ?? "",

      /// Parsed fields
      thumbnail: _parseThumbnail(json["thumbnail"]),
      ingredients: _parseIngredients(json["ingredients"]),
      missingIngredients: _parseIngredients(json["missing_items_list"]),

      /// NEW FIELDS
      expiringItems: _safeList(json["expiring_items"]),
      expiringItemsCount: json["expiring_items_count"] ?? 0,
      expiringItemsUsed: List<String>.from(json["expiring_items_used"] ?? []),
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
      "recipeId": recipeId,
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
