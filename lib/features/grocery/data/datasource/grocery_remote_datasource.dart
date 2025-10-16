import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class GroceryRemoteDatasource {
  Future<List<Map<String, dynamic>>> getUserRequestedItems({
    required String kitchenId,
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
}
