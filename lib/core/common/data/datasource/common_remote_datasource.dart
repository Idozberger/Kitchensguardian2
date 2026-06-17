import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/network/profile_response_cache.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

abstract interface class CommonRemoteDatasource {
  Future<List<Map<String, dynamic>>> getAllStorageArea({
    required String kitchenId,
  });
  Future<Map<String, dynamic>> getProfileData();
}

class CommonRemoteDatasourceImpl implements CommonRemoteDatasource {
  CommonRemoteDatasourceImpl({
    required this.dio,
    required this.profileCache,
  });

  final DioHelper dio;
  final ProfileResponseCache profileCache;

  @override
  Future<List<Map<String, dynamic>>> getAllStorageArea({
    required String kitchenId,
  }) async {
    int retries = 3;

    while (retries > 0) {
      try {
        final response = await dio.get(
          "${AppConstants.getPantries}?kitchen_id=$kitchenId",
        );

        if (response.statusCode != 200 && response.statusCode != 201) {
          final Map<String, dynamic> errBody = jsonObjectFromResponseData(
            response.data,
          );

          final Object? message = errBody['error'];
          throw apiExceptionFrom(message);
        }

        final Map<String, dynamic> body = jsonObjectFromResponseData(
          response.data,
        );
        final Object? pantriesRaw = body['pantries'];

        if (pantriesRaw is List) {
          return List<Map<String, dynamic>>.from(
            pantriesRaw.map(jsonObjectFromResponseData),
          );
        } else {
          throw Exception('Invalid response format');
        }
      } on DioException catch (e) {
        retries--;

        if (retries == 0) {
          throw await dio.handleError(e);
        }

        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    throw Exception('Unexpected error');
  }

  @override
  Future<Map<String, dynamic>> getProfileData() async {
    return profileCache.getOrFetch(_loadProfileFromNetwork);
  }

  Future<Map<String, dynamic>> _loadProfileFromNetwork() async {
    try {
      final response = await dio.get(AppConstants.getUserProfile);

      if (response.statusCode != 200 && response.statusCode != 201) {
        devLog(response.data.toString());
        final Map<String, dynamic> errBody = jsonObjectFromResponseData(
          response.data,
        );

        final Object? err = errBody['error'];
        throw apiExceptionFrom(err ?? 'Unknown error occurred');
      }

      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? avatar = data['avatar'];
      Uint8List? avatarBytes;

      if (avatar != null && avatar.toString().isNotEmpty) {
        try {
          final base64String = avatar.toString().contains(',')
              ? avatar.toString().split(',').last
              : avatar.toString();
          avatarBytes = base64Decode(base64String);
        } catch (e) {
          devLog('Avatar decode error: $e');
          avatarBytes = null;
        }
      }

      return {
        'avatar': avatarBytes,
        'first_name': data['first_name'] ?? '',
        'last_name': data['last_name'] ?? '',
        'email': data['email'] ?? '',
        'user_id': data['user_id'] ?? '',
        'verified': data['verified'] ?? false,
        'created_at': data['created_at'] ?? '',
        'entitlement_is_active': data['entitlement_is_active'] == true,
      };
    } catch (e, s) {
      devLog('getProfileData error: $e\n$s');
      return {};
    }
  }
}
