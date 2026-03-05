import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodkitchen/core/common/data/model/pantry_model.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/features/planner/domain/entities/meal_plan_entity.dart';

abstract interface class PlannerRemoteDatasource {
  Future<List<Map<String, dynamic>>> generateRecipes({
    required String instructions,
    required String kitchenId,
  });
  Future<List<Map<String, dynamic>>> favouriteRecipes();
  Future<String> addToFavourite({required String recipeId});
  Future<String> removeFromFavourite({required String recipeId});
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
  }) async {
    try {
      final response = await dio.post(
        AppConstants.generateRecipes,
        data: {
          "instructions":
              "$instructions. Note: Generate recipes that have approximately mentioned calories only. Do not exceed or go below this number significantly.",
          "kitchen_id": kitchenId,
        },
      );

      final data = response.data["recipes"];

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      if (data is List) {
        return data.map<Map<String, dynamic>>((e) {
          final recipe = Map<String, dynamic>.from(e);
          debugPrint(recipe.toString());
          final thumbnailBase64 = recipe["thumbnail"];

          if (thumbnailBase64 is String && thumbnailBase64.isNotEmpty) {
            try {
              recipe["thumbnail"] = base64Decode(
                thumbnailBase64.contains(",")
                    ? thumbnailBase64.split(",").last.trim()
                    : thumbnailBase64.trim(),
              );
            } catch (e) {
              recipe["thumbnail"] = Uint8List(0);
            }
          }
          return recipe;
        }).toList();
      } else {
        throw Exception("Invalid data format for favourite_recipes");
      }
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> favouriteRecipes() async {
    try {
      final response = await dio.get(AppConstants.favouriteRecipes);

      final data = response.data["favourite_recipes"];
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      if (data is List) {
        return data.map<Map<String, dynamic>>((e) {
          final recipe = Map<String, dynamic>.from(e);

          final thumbnailBase64 = recipe["thumbnail"];

          if (thumbnailBase64 is String && thumbnailBase64.isNotEmpty) {
            try {
              recipe["thumbnail"] = base64Decode(
                thumbnailBase64.contains(",")
                    ? thumbnailBase64.split(",").last.trim()
                    : thumbnailBase64.trim(),
              );
            } catch (e) {
              recipe["thumbnail"] = Uint8List(0);
            }
          }
          return recipe;
        }).toList();
      } else {
        throw Exception("Invalid data format for favourite_recipes");
      }
    } on DioException catch (e) {
      final failure = await dio.handleError(e);

      throw failure;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> addToFavourite({required String recipeId}) async {
    try {
      final response = await dio.post(
        AppConstants.addToFavourite,
        data: {"_id": recipeId},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> removeFromFavourite({required String recipeId}) async {
    try {
      final response = await dio.post(
        AppConstants.removeFromFavourite,
        data: {"recipe_id": recipeId},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["message"];
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  @override
  Future<String> markRecipeFinished({
    required String kitchenId,
    required String recipeId,
  }) async {
    try {
      log("recipeId: $recipeId kitchenId: $kitchenId");
      final response = await dio.post(
        AppConstants.markRecipeFinished,
        data: {"recipe_id": recipeId, "kitchen_id": kitchenId},
      );
      log("recipeId: response ${response.data}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["message"];
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  @override
  Future<String> requestItems({required PantryModel pantryModel}) async {
    try {
      final response = await dio.post(
        AppConstants.requestItems,
        data: pantryModel.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> createPlan({required List<MealPlanEntity> mealPlans}) async {
    try {
      List<String> responses = [];

      for (final meal in mealPlans) {
        final response = await dio.post(
          AppConstants.createMealPlan,
          data: {
            "date": meal.date,
            "kitchen_id": meal.kitchenId,
            "meal_type": meal.mealType,
            "notes": meal.notes,
            "recipe_id": meal.recipeId,
          },
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          final data = response.data is String
              ? jsonDecode(response.data)
              : response.data;

          throw data["error"];
        }

        responses.add(response.data["message"]);
      }

      return responses.join(", ");
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  @override
  Future<String> deletePlanFromRemoteDb({
    required String mealPlanId,
    required String kitchenId,
    required String date,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.deleteMealPlan,
        data: {
          "meal_plan_id": mealPlanId,
          "kitchen_id": kitchenId,
          "date": date,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> updateMealPlan({
    required String mealPlanId,
    required String mealType,
    required String notes,
    required String recipeId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.updateMealPlan,
        data: {
          "meal_plan_id": mealPlanId,
          "meal_type": mealType,
          "notes": notes,
          "recipe_id": recipeId,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> getMealByDate({
    required String kitchenId,
    required String date,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.getMealByDate}?get_by_date=$date?kitchen_id=$kitchenId",
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> listAllMealPlans({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.listAllMealPlans}?kitchen_id=$kitchenId",
      );

      final raw = response.data;

      if (raw is String && raw.trim().startsWith("<!doctype html")) {
        log("⚠ HTML returned instead of JSON. Returning empty list.");
        return [];
      }

      final data = raw["meal_plans"];

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      if (data is List) {
        return data.map<Map<String, dynamic>>((e) {
          final recipe = Map<String, dynamic>.from(e);

          final thumbnailBase64 = recipe["thumbnail"];

          if (thumbnailBase64 is String && thumbnailBase64.isNotEmpty) {
            try {
              recipe["thumbnail"] = base64Decode(
                thumbnailBase64.contains(",")
                    ? thumbnailBase64.split(",").last.trim()
                    : thumbnailBase64.trim(),
              );
            } catch (e) {
              recipe["thumbnail"] = Uint8List(0);
            }
          }
          return recipe;
        }).toList();
      } else {
        throw Exception("Invalid data format for favourite_recipes");
      }
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getDateRange({required String kitchenId}) async {
    try {
      final response = await dio.get(
        "${AppConstants.getDateRange}?kitchen_id=$kitchenId",
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      log("date ranges: ${response.data}");
      return response.data;
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> setDateRange({
    required String kitchenId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.setDateRange,
        data: {
          "kitchen_id": kitchenId,
          "start_date": startDate,
          "end_date": endDate,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }

      return response.data;
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
