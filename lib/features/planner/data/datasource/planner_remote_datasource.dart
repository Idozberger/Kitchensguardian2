import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class PlannerRemoteDatasource {
  Future<List<Map<String, dynamic>>> generateRecipes({
    required String instructions,
    required String kitchenId,
  });
}

class PlannerRemoteDatasourceImpl implements PlannerRemoteDatasource {
  final DioHelper dio;
  PlannerRemoteDatasourceImpl(this.dio);
  @override
  Future<List<Map<String, dynamic>>> generateRecipes({
    required String instructions,
    required String kitchenId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.generateRecipes,
        data: {"instructions": instructions, "kitchen_id": kitchenId},
      );
      final data = response.data["recipes"];

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
