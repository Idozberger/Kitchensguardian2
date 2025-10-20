import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class GroceryRemoteDatasource {
  Future<List<Map<String, dynamic>>> getUserRequestedItems({
    required String kitchenId,
  });
  Future<List<Map<String, dynamic>>> getAiGeneratedItems({
    required String kitchenId,
  });
  Future<List<Map<String, dynamic>>> updateBucketType({
    required String kitchenId,
    required List<String> itemsIds,
    required String bucketType,
  });
  Future<List<Map<String, dynamic>>> addMyListToKitchenInventory({
    required String kitchenId,
  });
  Future<List<Map<String, dynamic>>> deleteKitchenItems({
    required String kitchenId,
    required List<String> itemsIds,
  });
}

class GroceryRemoteDatasourceImpl implements GroceryRemoteDatasource {
  final DioHelper dio;
  GroceryRemoteDatasourceImpl(this.dio);
  @override
  Future<List<Map<String, dynamic>>> getUserRequestedItems({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.getRequestedItems}?kitchen_id=$kitchenId",
      );

      final data = response.data["user_items"];

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
  Future<List<Map<String, dynamic>>> updateBucketType({
    required String kitchenId,
    required List<String> itemsIds,
    required String bucketType,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.updateBucketType,
        data: {
          "kitchen_id": kitchenId,
          "item_ids": itemsIds,
          "bucket_type": bucketType,
        },
      );

      return await getUserRequestedItems(kitchenId: kitchenId);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> addMyListToKitchenInventory({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.addMyListItemToKitchenInventory,
        data: {"kitchen_id": kitchenId},
      );

      return await getUserRequestedItems(kitchenId: kitchenId);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAiGeneratedItems({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.getAiGeneratedList}?kitchen_id=$kitchenId",
      );

      final data = response.data["missing_items"];

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
  Future<List<Map<String, dynamic>>> deleteKitchenItems({
    required String kitchenId,
    required List<String> itemsIds,
  }) async {
    try {
      await dio.post(
        AppConstants.deleteKitchenItems,
        data: {"kitchen_id": kitchenId, "item_ids": itemsIds},
      );

      return await getUserRequestedItems(kitchenId: kitchenId);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
