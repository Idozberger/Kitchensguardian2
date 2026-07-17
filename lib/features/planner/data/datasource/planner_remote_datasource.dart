import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/common/data/model/pantry_model.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/planner/domain/entities/meal_plan_entity.dart';

part 'planner_remote_datasource_impl_part.dart';
part 'planner_remote_datasource_impl_part2.dart';

List<Map<String, dynamic>> _plannerDecodeRecipeThumbnailList(Object? raw) {
  if (raw is! List) {
    throw Exception("Invalid data format for favourite_recipes");
  }
  return raw.map<Map<String, dynamic>>((Object? e) {
    final Map<String, dynamic> recipe = jsonObjectFromResponseData(e);
    final Object? thumbnailBase64 = recipe['thumbnail'];
    if (thumbnailBase64 is String && thumbnailBase64.isNotEmpty) {
      try {
        recipe['thumbnail'] = base64Decode(
          thumbnailBase64.contains(',')
              ? thumbnailBase64.split(',').last.trim()
              : thumbnailBase64.trim(),
        );
      } catch (_) {
        recipe['thumbnail'] = null;
      }
    }
    return recipe;
  }).toList();
}

abstract interface class PlannerRemoteDatasource {
  Future<List<Map<String, dynamic>>> generateRecipes({
    required String instructions,
    required String kitchenId,
    String? keywords,
  });
  Future<List<Map<String, dynamic>>> favouriteRecipes({
    required String kitchenId,
  });
  Future<String> addToFavourite({
    required String recipeId,
    required String kitchenId,
  });
  Future<String> removeFromFavourite({
    required String recipeId,
    required String kitchenId,
  });
  Future<String> markRecipeFinished({
    required String kitchenId,
    required String recipeId,
  });
  Future<String> requestItems({required PantryModel pantryModel});
  Future<String> createPlan({required List<MealPlanEntity> mealPlans});
  Future<String> deletePlanFromRemoteDb({
    required String mealPlanId,
    required String kitchenId,
    required String date,
  });
  Future<String> updateMealPlan({
    required String mealPlanId,
    required String mealType,
    required String notes,
    required String recipeId,
  });
  Future<String> getMealByDate({
    required String kitchenId,
    required String date,
  });
  Future<bool> checkMissingIngredients({
    required String kitchenId,
    required String recipeId,
  });
  Future<List<Map<String, dynamic>>> listAllMealPlans({
    required String kitchenId,
  });
  Future<Map<String, dynamic>> getDateRange({required String kitchenId});
  Future<Map<String, dynamic>> setDateRange({
    required String kitchenId,
    required String startDate,
    required String endDate,
  });
}

class PlannerRemoteDatasourceImpl implements PlannerRemoteDatasource {
  final DioHelper dio;
  PlannerRemoteDatasourceImpl(this.dio);

  @override
  Future<List<Map<String, dynamic>>> generateRecipes({
    required String instructions,
    required String kitchenId,
    String? keywords,
  }) => _plannerImplGenerateRecipes(
    this,
    instructions: instructions,
    kitchenId: kitchenId,
    keywords: keywords,
  );

  @override
  Future<List<Map<String, dynamic>>> favouriteRecipes({
    required String kitchenId,
  }) => _plannerImplFavouriteRecipes(this, kitchenId: kitchenId);

  @override
  Future<String> addToFavourite({
    required String recipeId,
    required String kitchenId,
  }) => _plannerImplAddToFavourite(
    this,
    recipeId: recipeId,
    kitchenId: kitchenId,
  );

  @override
  Future<String> removeFromFavourite({
    required String recipeId,
    required String kitchenId,
  }) => _plannerImplRemoveFromFavourite(
    this,
    recipeId: recipeId,
    kitchenId: kitchenId,
  );

  @override
  Future<String> markRecipeFinished({
    required String kitchenId,
    required String recipeId,
  }) => _plannerImplMarkRecipeFinished(
    this,
    kitchenId: kitchenId,
    recipeId: recipeId,
  );

  @override
  Future<String> requestItems({required PantryModel pantryModel}) =>
      _plannerImplRequestItems(this, pantryModel: pantryModel);

  @override
  Future<String> createPlan({required List<MealPlanEntity> mealPlans}) =>
      _plannerImplCreatePlan(this, mealPlans: mealPlans);

  @override
  Future<String> deletePlanFromRemoteDb({
    required String mealPlanId,
    required String kitchenId,
    required String date,
  }) => _plannerImplDeletePlanFromRemoteDb(
    this,
    mealPlanId: mealPlanId,
    kitchenId: kitchenId,
    date: date,
  );

  @override
  Future<String> updateMealPlan({
    required String mealPlanId,
    required String mealType,
    required String notes,
    required String recipeId,
  }) => _plannerImplUpdateMealPlan(
    this,
    mealPlanId: mealPlanId,
    mealType: mealType,
    notes: notes,
    recipeId: recipeId,
  );

  @override
  Future<String> getMealByDate({
    required String kitchenId,
    required String date,
  }) => _plannerImplGetMealByDate(this, kitchenId: kitchenId, date: date);

  @override
  Future<List<Map<String, dynamic>>> listAllMealPlans({
    required String kitchenId,
  }) => _plannerImplListAllMealPlans(this, kitchenId: kitchenId);

  @override
  Future<Map<String, dynamic>> getDateRange({required String kitchenId}) =>
      _plannerImplGetDateRange(this, kitchenId: kitchenId);

  @override
  Future<Map<String, dynamic>> setDateRange({
    required String kitchenId,
    required String startDate,
    required String endDate,
  }) => _plannerImplSetDateRange(
    this,
    kitchenId: kitchenId,
    startDate: startDate,
    endDate: endDate,
  );

  @override
  Future<bool> checkMissingIngredients({
    required String kitchenId,
    required String recipeId,
  }) => _plannerImplCheckMissingIngredients(
    this,
    kitchenId: kitchenId,
    recipeId: recipeId,
  );
}
