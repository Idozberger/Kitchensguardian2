import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class HomeRemoteDataSource {
  Future<Map<String, dynamic>> createKitchen({required String kitchenName});
  Future<String> joinKitchen({required String invitationCode});
  Future<List<Map<String, dynamic>>> getPantriesItems({
    required String kitchenId,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SharedPreferences sharedPreferences;
  final DioHelper dio;
  HomeRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });
  @override
  Future<Map<String, dynamic>> createKitchen({
    required String kitchenName,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.createKitchen,
        data: {"kitchen_name": kitchenName},
      );
      sharedPreferences.setString("kitchen_id", response.data["kitchen_id"]);
      sharedPreferences.setString(
        "invitation_code",
        response.data["invitation_code"],
      );

      return response.data;
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> joinKitchen({required String invitationCode}) async {
    try {
      final response = await dio.post(
        AppConstants.joinKitchen,
        data: {"invitation_code": invitationCode},
      );
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPantriesItems({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.getPantryItems}?kitchen_id=$kitchenId",
      );
      final data = response.data["items"];

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
