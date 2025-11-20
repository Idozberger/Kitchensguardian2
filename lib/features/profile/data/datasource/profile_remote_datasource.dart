import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract class ProfileRemoteDatasource {
  Future<String> editProfile({
    required String firstName,
    required String lastName,
    required String thumbnail,
  });
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final DioHelper dio;
  ProfileRemoteDatasourceImpl({required this.dio});
  @override
  Future<String> editProfile({
    required String firstName,
    required String lastName,
    required String thumbnail,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.editUser,
        data: {
          "first_name": firstName,
          "last_name": lastName,
          "avatar": thumbnail,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.changePassword,
        data: {
          "current_password": currentPassword,
          "new_password": newPassword,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
