import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/features/pantry/data/model/pantry_model.dart';

abstract interface class PantryRemoteDatasource {
  Future<String> addPantryItem({required PantryModel pantryModel});
  Future<Map<String, dynamic>> getPantryItems({required String kitchenId});
}

class PantryRemoteDatasourceImpl implements PantryRemoteDatasource {
  final DioHelper dio;
  PantryRemoteDatasourceImpl(this.dio);
  @override
  Future<String> addPantryItem({required PantryModel pantryModel}) async {
    try {
      final response = await dio.post(
        AppConstants.addPantryItem,
        data: pantryModel.toJson(),
      );
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getPantryItems({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.getPantryItems}?kitchen_id=$kitchenId",
      );
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
