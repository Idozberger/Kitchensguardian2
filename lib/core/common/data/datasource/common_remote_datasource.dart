import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class CommonRemoteDatasource {
  Future<List<Map<String, dynamic>>> getAllPantries({
    required String kitchenId,
  });
  Future<String> createPantry({
    required String kitchenId,
    required List<String> pantries,
  });
}

class CommonRemoteDatasourceImpl implements CommonRemoteDatasource {
  final DioHelper dio;
  CommonRemoteDatasourceImpl({required this.dio});
  @override
  Future<List<Map<String, dynamic>>> getAllPantries({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.getPantries}?kitchen_id=$kitchenId",
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final data = response.data["pantries"];

      if (data is List) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception("Invalid response format");
      }
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> createPantry({
    required String kitchenId,
    required List<String> pantries,
  }) async {
    try {
      final pantryList = pantries.map((name) => {"pantry_name": name}).toList();

      final response = await dio.post(
        AppConstants.createPantry,
        data: {"kitchen_id": kitchenId, "pantries": pantryList},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data;
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
