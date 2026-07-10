part of 'package:foodkitchen/features/home/data/datasource/home_remote_datasource.dart';

Future<Map<String, dynamic>> _homeImplCreateKitchen(
  HomeRemoteDataSourceImpl ds, {
  required String kitchenName,
  required UnitSystem unitSystem,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.createKitchen,
      data: {
        "kitchen_name": kitchenName,
        "unit_system": unitSystemToApi(unitSystem),
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    final Map<String, dynamic> body = jsonObjectFromResponseData(response.data);
    ds.sharedPreferences.setString(
      "kitchen_id",
      readJsonString(body, 'kitchen_id'),
    );
    ds.sharedPreferences.setString(
      "invitation_code",
      readJsonString(body, 'invitation_code'),
    );

    return body;
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<Map<String, List<Map<String, dynamic>>>> _homeImplGetPantriesItems(
  HomeRemoteDataSourceImpl ds, {
  required String kitchenId,
}) async {
  try {
    final response = await ds.dio.get(
      "${AppConstants.getPantryItems}?kitchen_id=$kitchenId",
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    final Map<String, dynamic> root = jsonObjectFromResponseData(response.data);
    final Object? items = root['items'];

    if (items is List) {
      final parsedItems = items.map(jsonObjectFromResponseData).toList();

      return {"items": parsedItems, "pantry_types": []};
    } else {
      throw Exception("Invalid data format");
    }
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  } catch (e) {
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> _homeImplGetWeeklyPlans(
  HomeRemoteDataSourceImpl ds, {
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

    final Object? data = root['meal_plans'];

    if (data is List) {
      return data.map<Map<String, dynamic>>((Object? e) {
        final Map<String, dynamic> recipe = jsonObjectFromResponseData(e);

        final Object? thumbnailBase64 = recipe['thumbnail'];

        if (thumbnailBase64 is String && thumbnailBase64.isNotEmpty) {
          try {
            recipe['thumbnail'] = base64Decode(
              thumbnailBase64.contains(",")
                  ? thumbnailBase64.split(',').last.trim()
                  : thumbnailBase64.trim(),
            );
          } catch (e) {
            recipe['thumbnail'] = null;
          }
        }
        return recipe;
      }).toList();
    } else {
      throw Exception("Invalid data format for favourite_recipes");
    }
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<Map<String, dynamic>> _homeImplGetRecipeSuggestion(
  HomeRemoteDataSourceImpl ds, {
  required String kitchenId,
}) async {
  try {
    final response = await ds.dio.get(
      "${AppConstants.suggestRecipe}?kitchen_id=$kitchenId",
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      devPrint("Suggested Recipe: $message");
      throw apiExceptionFrom('Server error, please try again');
    }
    return jsonObjectFromResponseData(response.data);
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  } catch (e) {
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> _homeImplGetAllRequestedItems(
  HomeRemoteDataSourceImpl ds, {
  required String kitchenId,
}) async {
  try {
    final url =
        "${AppConstants.baseUrl}/api/kitchen/item_requests?kitchen_id=$kitchenId&status=all";
    devLog("[API] Fetching all requested items from URL: $url");

    final response = await ds.dio.get(url);
    devLog("[API] Response received with status code: ${response.statusCode}");

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'] ?? 'Unknown error';
      devLog("[API] Error fetching requested items: $message");
      throw apiExceptionFrom(message);
    }

    final Map<String, dynamic> root = jsonObjectFromResponseData(response.data);
    final Object? data = root['requests'];

    if (data is List) {
      final parsedList = data.map(jsonObjectFromResponseData).toList();

      devLog("[API] Total requested items parsed: ${parsedList.length}");
      return parsedList;
    } else {
      devLog(
        "[API] Invalid data format, expected List, got: ${data.runtimeType}",
      );
      throw Exception("Invalid data");
    }
  } on DioException catch (e) {
    devLog("[API] DioException occurred: ${e.message}");
    final Object error = await ds.dio.handleError(e);
    devLog("[API] Processed Dio error: $error");
    throw error;
  } catch (e, stackTrace) {
    devLog("[API] Unexpected exception: $e");
    devLog("[API] Stack trace: $stackTrace");
    rethrow;
  }
}

Future<String> _homeImplRespondToItemRequest(
  HomeRemoteDataSourceImpl ds, {
  required String action,
  required String rejectReason,
  required String requestId,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.repondToItemRequest,
      data: {
        "action": action,
        "reject_reason": rejectReason,
        "request_id": requestId,
      },
    );
    devLog("respond request: $response");
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      devPrint("Suggested Recipe: $message");
      throw apiExceptionFrom('Server error, please try again');
    }
    final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
    return readJsonString(ok, 'message');
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  } catch (e) {
    rethrow;
  }
}
