part of 'package:foodkitchen/features/grocery/data/datasource/grocery_remote_datasource.dart';

String _groceryGenerateUniqueId() {
  return "ai_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}";
}

Future<List<Map<String, dynamic>>> _groceryImplGetUserRequestedItems(
  GroceryRemoteDatasourceImpl ds, {
  required String kitchenId,
}) async {
  try {
    final response = await ds.dio.get(
      "${AppConstants.getRequestedItems}?kitchen_id=$kitchenId",
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    final Map<String, dynamic> root = jsonObjectFromResponseData(response.data);
    final Object? itemsRaw = root['items'];

    if (itemsRaw is List) {
      return itemsRaw.map(jsonObjectFromResponseData).toList();
    } else {
      throw Exception("Invalid data");
    }
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<List<Map<String, dynamic>>> _groceryImplUpdateBucketType(
  GroceryRemoteDatasourceImpl ds, {
  required String kitchenId,
  required List<String> itemsIds,
  required String bucketType,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.updateBucketType,
      data: {
        "kitchen_id": kitchenId,
        "item_ids": itemsIds,
        "bucket_type": bucketType,
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    return await _groceryImplGetUserRequestedItems(ds, kitchenId: kitchenId);
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<List<Map<String, dynamic>>> _groceryImplAddMyListToKitchenInventory(
  GroceryRemoteDatasourceImpl ds, {
  required String kitchenId,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.addMyListItemToKitchenInventory,
      data: {"kitchen_id": kitchenId},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    return await _groceryImplGetUserRequestedItems(ds, kitchenId: kitchenId);
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<List<Map<String, dynamic>>> _groceryImplGetAiGeneratedItems(
  GroceryRemoteDatasourceImpl ds, {
  required String kitchenId,
}) async {
  try {
    final response = await ds.dio.get(
      "${AppConstants.getAiGeneratedList}?kitchen_id=$kitchenId",
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );
      final Object? message = data['error'] ?? 'Failed to fetch AI items';
      throw apiExceptionFrom(message);
    }

    final Map<String, dynamic> root = jsonObjectFromResponseData(response.data);
    final Object? data = root['missing_items'];

    if (data is! List) {
      throw Exception("Expected list of items, got: ${data.runtimeType}");
    }

    devLog("Raw AI generated items: $data");

    final List<Map<String, dynamic>> parsedList = data.map((Object? item) {
      if (item is Map<String, dynamic>) {
        final Map<String, dynamic> map = Map<String, dynamic>.from(item);

        if (!map.containsKey("item_id") || map["item_id"] == null) {
          map["item_id"] = _groceryGenerateUniqueId();
        }
        return map;
      } else if (item is String) {
        return {
          "item_id": _groceryGenerateUniqueId(),
          "name": item.trim(),
          "is_custom": true,
        };
      } else {
        return {
          "item_id": _groceryGenerateUniqueId(),
          "name": item.toString(),
          "is_custom": true,
        };
      }
    }).toList();

    devLog("Parsed AI items with item_id: $parsedList");
    return parsedList;
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  } catch (e, stackTrace) {
    devPrint("Error in getAiGeneratedItems: $e");
    devPrint("StackTrace: $stackTrace");
    rethrow;
  }
}

Future<List<Map<String, dynamic>>> _groceryImplDeleteKitchenItems(
  GroceryRemoteDatasourceImpl ds, {
  required String kitchenId,
  required List<String> itemsIds,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.deleteKitchenItems,
      data: {"kitchen_id": kitchenId, "item_ids": itemsIds},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    return await _groceryImplGetUserRequestedItems(ds, kitchenId: kitchenId);
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<List<Map<String, dynamic>>> _groceryImplAddCustomItems(
  GroceryRemoteDatasourceImpl ds, {
  required String kitchenId,
  required String name,
  required String quantity,
  required String unit,
  required String bucketType,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.addItemToList,
      data: {
        "kitchen_id": kitchenId,
        "name": name,
        "quantity": quantity,
        "unit": unit,
        "bucket_type": bucketType,
      },
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    return await _groceryImplGetUserRequestedItems(ds, kitchenId: kitchenId);
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<String> _groceryImplGenerateAutoGeneratedList(
  GroceryRemoteDatasourceImpl ds, {
  required String kitchenId,
  required String date,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.generateAutoGeneratedList,
      data: {"kitchen_id": kitchenId, "date": date},
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

Future<String> _groceryImplEditGroceryListItem(
  GroceryRemoteDatasourceImpl ds, {
  required String kitchenId,
  required String itemId,
  required String name,
  required String quantity,
  required String unit,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.editGroceryListItem,
      data: {
        "item_id": itemId,
        "kitchen_id": kitchenId,
        "name": name,
        "quantity": quantity,
        "unit": unit,
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
