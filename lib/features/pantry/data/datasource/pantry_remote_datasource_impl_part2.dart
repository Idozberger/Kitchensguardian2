part of 'package:foodkitchen/features/pantry/data/datasource/pantry_remote_datasource.dart';

Future<String> _pantryImplDeleteItem(
  PantryRemoteDatasourceImpl ds, {
  required PantryModel pantryModel,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.removeItems,
      data: {
        "item_ids": [pantryModel.items[0].itemId],
        "kitchen_id": pantryModel.kitchenId,
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
  } catch (e) {
    rethrow;
  }
}

Future<String> _pantryImplUpdateItem(
  PantryRemoteDatasourceImpl ds, {
  required PantryModel pantryModel,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.updateKitchenItems,
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
  } catch (e) {
    rethrow;
  }
}

Future<String> _pantryImplAddRequestItem(
  PantryRemoteDatasourceImpl ds, {
  required PantryModel pantryModel,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.addPantryRequestItems,
      data: pantryModel.toJson(),
    );
    devLog("add pantry status: $response");
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
