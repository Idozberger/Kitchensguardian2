part of 'package:foodkitchen/features/planner/data/datasource/planner_remote_datasource.dart';

Future<List<Map<String, dynamic>>> _plannerImplGenerateRecipes(
  PlannerRemoteDatasourceImpl ds, {
  required String instructions,
  required String kitchenId,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.generateRecipes,
      data: {
        "instructions":
            "$instructions. Note: Generate recipes that have approximately mentioned calories only. Do not exceed or go below this number significantly.",
        "kitchen_id": kitchenId,
      },
    );

    final Map<String, dynamic> root = jsonObjectFromResponseData(response.data);

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Object? message = root['error'];
      throw apiExceptionFrom(message);
    }
    return _plannerDecodeRecipeThumbnailList(root['recipes']);
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<List<Map<String, dynamic>>> _plannerImplFavouriteRecipes(
  PlannerRemoteDatasourceImpl ds, {
  required String kitchenId,
}) async {
  try {
    final response = await ds.dio.get(
      "${AppConstants.favouriteRecipes}?kitchen_id=$kitchenId",
    );

    final Map<String, dynamic> root = jsonObjectFromResponseData(response.data);

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Object? message = root['error'];
      throw apiExceptionFrom(message);
    }
    return _plannerDecodeRecipeThumbnailList(root['favourite_recipes']);
  } on DioException catch (e) {
    final Object failure = await ds.dio.handleError(e);

    throw failure;
  } catch (e) {
    rethrow;
  }
}

Future<String> _plannerImplAddToFavourite(
  PlannerRemoteDatasourceImpl ds, {
  required String recipeId,
  required String kitchenId,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.addToFavourite,
      data: {"_id": recipeId, "kitchen_id": kitchenId},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
    return readJsonString(ok, 'message');
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<String> _plannerImplRemoveFromFavourite(
  PlannerRemoteDatasourceImpl ds, {
  required String recipeId,
  required String kitchenId,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.removeFromFavourite,
      data: {"recipe_id": recipeId, "kitchen_id": kitchenId},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
    return readJsonString(ok, 'message');
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<String> _plannerImplMarkRecipeFinished(
  PlannerRemoteDatasourceImpl ds, {
  required String kitchenId,
  required String recipeId,
}) async {
  try {
    devLog("recipeId: $recipeId kitchenId: $kitchenId");
    final response = await ds.dio.post(
      AppConstants.markRecipeFinished,
      data: {"recipe_id": recipeId, "kitchen_id": kitchenId},
    );
    devLog("recipeId: response ${response.data}");
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
    return readJsonString(ok, 'message');
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<String> _plannerImplRequestItems(
  PlannerRemoteDatasourceImpl ds, {
  required PantryModel pantryModel,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.requestItems,
      data: pantryModel.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
    return readJsonString(ok, 'message');
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}
