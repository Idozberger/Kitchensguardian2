import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

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

      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception("Invalid data");
      }
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> favouriteRecipes() async {
    try {
      final response = await dio.get(AppConstants.favouriteRecipes);
      final data = response.data["favourite_recipes"];

      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception("Invalid data");
      }
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> addToFavourite({required String recipeId}) async {
    try {
      final response = await dio.post(
        AppConstants.addToFavourite,
        data: {"_id": recipeId},
      );

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

      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> markRecipeFinished({
    required String kitchenId,
    required String recipeId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.markRecipeFinished,
        data: {"recipe_id": recipeId, "kitchen_id": kitchenId},
      );

      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
