import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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
  Future<List<Map<String, dynamic>>> addCustomItems({
    required String kitchenId,
    required String name,
    required String quantity,
    required String unit,
    required String bucketType,
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
      debugPrint(
        "🔹 [getAiGeneratedItems] Request started for kitchenId: $kitchenId",
      );

      final response = await dio.get(
        "${AppConstants.getAiGeneratedList}?kitchen_id=$kitchenId",
      );

      debugPrint("✅ [getAiGeneratedItems] Response: ${response.data}");

      final data = response.data["missing_items"];

      if (data is List) {
        final parsedList = data.map<Map<String, dynamic>>((e) {
          if (e is Map) {
            return Map<String, dynamic>.from(e);
          } else if (e is String) {
            return {"name": e};
          } else {
            debugPrint(
              "⚠️ [getAiGeneratedItems] Unknown item type: ${e.runtimeType}",
            );
            return {"name": e.toString()};
          }
        }).toList();

        debugPrint(
          "📦 [getAiGeneratedItems] Parsed ${parsedList.length} items",
        );
        return parsedList;
      } else {
        debugPrint(
          "⚠️ [getAiGeneratedItems] Invalid data format: ${response.data}",
        );
        throw Exception("Invalid data");
      }
    } on DioException catch (e) {
      debugPrint("❌ [getAiGeneratedItems] DioException: ${e.message}");
      throw dio.handleError(e);
    } catch (e, stackTrace) {
      debugPrint("🚨 [getAiGeneratedItems] Unexpected error: $e");
      debugPrint("🧩 StackTrace: $stackTrace");
      rethrow;
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

  @override
  Future<List<Map<String, dynamic>>> addCustomItems({
    required String kitchenId,
    required String name,
    required String quantity,
    required String unit,
    required String bucketType,
  }) async {
    try {
      await dio.post(
        AppConstants.addItemToList,
        data: {
          "kitchen_id": kitchenId,
          "name": name,
          "quantity": quantity,
          "unit": unit,
          "bucket_type": bucketType,
        },
      );

      return await getUserRequestedItems(kitchenId: kitchenId);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
