import 'dart:convert';
import 'dart:developer';
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
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
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
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
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
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        final message = data["error"] ?? "Failed to fetch AI items";
        throw message;
      }

      final data = response.data["missing_items"];

      if (data is! List) {
        throw Exception("Expected list of items, got: ${data.runtimeType}");
      }

      log("Raw AI generated items: $data");

      final List<Map<String, dynamic>> parsedList = data.map((item) {
        if (item is Map<String, dynamic>) {
          final map = Map<String, dynamic>.from(item);

          if (!map.containsKey("item_id") || map["item_id"] == null) {
            map["item_id"] = _generateUniqueId();
          }
          return map;
        } else if (item is String) {
          return {
            "item_id": _generateUniqueId(),
            "name": item.trim(),
            "is_custom": true,
          };
        } else {
          return {
            "item_id": _generateUniqueId(),
            "name": item.toString(),
            "is_custom": true,
          };
        }
      }).toList();

      log("Parsed AI items with item_id: $parsedList");
      return parsedList;
    } on DioException catch (e) {
      throw dio.handleError(e);
    } catch (e, stackTrace) {
      debugPrint("Error in getAiGeneratedItems: $e");
      debugPrint("StackTrace: $stackTrace");
      rethrow;
    }
  }

  String _generateUniqueId() {
    return "ai_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch}";
  }

  @override
  Future<List<Map<String, dynamic>>> deleteKitchenItems({
    required String kitchenId,
    required List<String> itemsIds,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.deleteKitchenItems,
        data: {"kitchen_id": kitchenId, "item_ids": itemsIds},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
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
      final response = await dio.post(
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
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return await getUserRequestedItems(kitchenId: kitchenId);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
