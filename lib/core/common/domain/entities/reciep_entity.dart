import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/common/domain/entities/expiring_item_entity.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';

class RecipeEntity {
  final String id;
  final String mealplanId;
  final String formatedDateString;
  final String mealType;
  final String title;
  final String calories;
  final String cookingTime;
  final String recipeShortSummary;
  final List<String> cookingSteps;
  final List<Map<String, dynamic>> doneSteps;
  final List<IngredientEntity> ingredients;
  final List<IngredientEntity> missingIngredients;
  final Uint8List? thumbnail;
  bool missingItems;
  final bool available;

  final String recipeId;
  final String kitchenId;
  final String date;
  final String createdAt;
  final String updatedAt;
  final String createdBy;
  final bool isCompleted;
  final String notes;

  final int expiringItemsCount;
  final List<ExpiringItemEntity> expiringItems;
  final List<String> expiringItemsUsed;

  RecipeEntity({
    required this.id,
    required this.mealplanId,
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
    required this.thumbnail,
    required this.missingIngredients,
    this.doneSteps = const [],
    required this.recipeId,
    required this.kitchenId,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.isCompleted,
    required this.notes,
    this.expiringItemsCount = 0,
    this.expiringItems = const [],
    this.expiringItemsUsed = const [],
  });
}
