part of 'package:foodkitchen/features/planner/data/datasource/planner_remote_datasource.dart';

Future<String> _plannerImplCreatePlan(
  PlannerRemoteDatasourceImpl ds, {
  required List<MealPlanEntity> mealPlans,
}) async {
  try {
    List<String> responses = [];

    for (final meal in mealPlans) {
      final response = await ds.dio.post(
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
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        throw apiExceptionFrom(data['error']);
      }

      final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
      responses.add(readJsonString(ok, 'message'));
    }

    return responses.join(", ");
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<String> _plannerImplDeletePlanFromRemoteDb(
  PlannerRemoteDatasourceImpl ds, {
  required String mealPlanId,
  required String kitchenId,
  required String date,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.deleteMealPlan,
      data: {"meal_plan_id": mealPlanId, "kitchen_id": kitchenId, "date": date},
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

Future<String> _plannerImplUpdateMealPlan(
  PlannerRemoteDatasourceImpl ds, {
  required String mealPlanId,
  required String mealType,
  required String notes,
  required String recipeId,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.updateMealPlan,
      data: {
        "meal_plan_id": mealPlanId,
        "meal_type": mealType,
        "notes": notes,
        "recipe_id": recipeId,
      },
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

Future<String> _plannerImplGetMealByDate(
  PlannerRemoteDatasourceImpl ds, {
  required String kitchenId,
  required String date,
}) async {
  try {
    final response = await ds.dio.get(
      "${AppConstants.getMealByDate}?get_by_date=$date?kitchen_id=$kitchenId",
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

Future<List<Map<String, dynamic>>> _plannerImplListAllMealPlans(
  PlannerRemoteDatasourceImpl ds, {
  required String kitchenId,
}) async {
  try {
    final response = await ds.dio.get(
      "${AppConstants.listAllMealPlans}?kitchen_id=$kitchenId",
    );

    final Object? raw = response.data;

    if (raw is String &&
        raw.trim().toLowerCase().startsWith("<!doctype html")) {
      devLog("⚠ HTML returned instead of JSON. Returning empty list.");
      return [];
    }

    final Map<String, dynamic> root = raw is String
        ? jsonObjectFromResponseData(jsonDecode(raw))
        : jsonObjectFromResponseData(raw);

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Object? message = root['error'];
      throw apiExceptionFrom(message);
    }
    return _plannerDecodeRecipeThumbnailList(root['meal_plans']);
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<Map<String, dynamic>> _plannerImplGetDateRange(
  PlannerRemoteDatasourceImpl ds, {
  required String kitchenId,
}) async {
  int retries = 3;

  while (retries > 0) {
    try {
      final response = await ds.dio.get(
        "${AppConstants.getDateRange}?kitchen_id=$kitchenId",
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        final Object? message = data['error'];
        throw apiExceptionFrom(message);
      }

      devLog("date ranges: ${response.data}");
      return jsonObjectFromResponseData(response.data);
    } on DioException catch (e) {
      retries--;

      if (retries == 0) {
        throw await ds.dio.handleError(e);
      }

      await Future<void>.delayed(const Duration(seconds: 1));
    }
  }

  throw Exception("Unexpected error");
}

Future<Map<String, dynamic>> _plannerImplSetDateRange(
  PlannerRemoteDatasourceImpl ds, {
  required String kitchenId,
  required String startDate,
  required String endDate,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.setDateRange,
      data: {
        "kitchen_id": kitchenId,
        "start_date": startDate,
        "end_date": endDate,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }

    return jsonObjectFromResponseData(response.data);
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<bool> _plannerImplCheckMissingIngredients(
  PlannerRemoteDatasourceImpl ds, {
  required String kitchenId,
  required String recipeId,
}) async {
  try {
    final response = await ds.dio.get(
      "${AppConstants.checkMissingIngredients}?recipe_id=$recipeId&kitchen_id=$kitchenId",
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    devLog("response of missing ingredients: $response");
    final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
    return readJsonBool(ok, 'has_missing_ingredients');
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}
