// ignore_for_file: unnecessary_brace_in_string_interps
// String templates use explicit `${id}` for readability with adjacent text.

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/network/profile_response_cache.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

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
  Future<String> deleteAccount();
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  ProfileRemoteDatasourceImpl({
    required DioHelper dio,
    required ProfileResponseCache profileCache,
  }) : _dio = dio,
       _profileCache = profileCache;

  final DioHelper _dio;
  final ProfileResponseCache _profileCache;
  @override
  Future<String> editProfile({
    required String firstName,
    required String lastName,
    required String thumbnail,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.editUser,
        data: {
          "first_name": firstName,
          "last_name": lastName,
          "avatar": thumbnail,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        final Object? message = data['error'];
        throw apiExceptionFrom(message);
      }
      _profileCache.invalidate();
      final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
      return readJsonString(ok, 'message');
    } on DioException catch (e) {
      throw await _dio.handleError(e);
    }
  }

  @override
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        AppConstants.changePassword,
        data: {
          "current_password": currentPassword,
          "new_password": newPassword,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        final Object? message = data['error'];
        throw apiExceptionFrom(message);
      }
      final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
      return readJsonString(ok, 'message');
    } on DioException catch (e) {
      throw await _dio.handleError(e);
    }
  }

  @override
  Future<String> deleteAccount() async {
    try {
      final response = await _dio.delete(AppConstants.deleteAccount);
      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        final Object? message = data['error'];
        throw apiExceptionFrom(message);
      }
      _profileCache.invalidate();
      final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
      return readJsonString(ok, 'message');
    } on DioException catch (e) {
      throw await _dio.handleError(e);
    }
  }
}
