import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class KitchenRemoteDatasource {
  Future<List<Map<String, dynamic>>> getKitchens();
  Future<String> leaveKitchen({required String kitchenId});
  Future<String> createKitchen({required String kitchenName});
  Future<String> joinKitchen({required String invitationCode});
  Future<String> removeKitchen({required String kitchenId});
  Future<String> inviteUser({required String email, required String kitchenId});
}

class KitchenRemoteDataSourceImpl implements KitchenRemoteDatasource {
  final DioHelper dio;
  final SharedPreferences sharedPreferences;
  KitchenRemoteDataSourceImpl(this.dio, this.sharedPreferences);
  @override
  Future<List<Map<String, dynamic>>> getKitchens() async {
    try {
      final response = await dio.get(AppConstants.kitchens);

      final data = response.data["kitchens"];

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
  Future<String> createKitchen({required String kitchenName}) async {
    try {
      final response = await dio.post(
        AppConstants.createKitchen,
        data: {"kitchen_name": kitchenName},
      );
      final data = response.data;

      final kitchenId = data["kitchen_id"];
      final invitationCode = data["invitation_code"];
      final role = data["role"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('kitchen_id', kitchenId.toString());
      await prefs.setString('invitation_code', invitationCode.toString());
      await prefs.setString('role', role.toString());
      return response.data["message"];
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
      final data = response.data;
      final kitchenId = data["kitchen_id"];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('kitchen_id', kitchenId.toString());

      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> leaveKitchen({required String kitchenId}) async {
    try {
      final response = await dio.post(
        AppConstants.leaveKitchen,
        data: {"kitchen_id": kitchenId},
      );
      await sharedPreferences.remove('kitchen_id');
      await sharedPreferences.remove('invitation_code');
      await sharedPreferences.remove('role');
      log(response.data["message"]);

      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> removeKitchen({required String kitchenId}) async {
    try {
      final response = await dio.post(
        AppConstants.removeKitchen,
        data: {"kitchen_id": kitchenId},
      );
      await sharedPreferences.remove('kitchen_id');
      await sharedPreferences.remove('invitation_code');
      await sharedPreferences.remove('role');

      log(response.data["message"]);

      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> inviteUser({
    required String email,
    required String kitchenId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.inviteUser,
        data: {"kitchen_id": kitchenId, "email": email},
      );

      log(response.data["message"]);

      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
