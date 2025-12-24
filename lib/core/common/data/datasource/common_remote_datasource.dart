import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class CommonRemoteDatasource {
  Future<List<Map<String, dynamic>>> getAllStorageArea({
    required String kitchenId,
  });
  Future<Map<String, dynamic>> getProfileData();
}

class CommonRemoteDatasourceImpl implements CommonRemoteDatasource {
  final DioHelper dio;
  CommonRemoteDatasourceImpl({required this.dio});
  @override
  Future<List<Map<String, dynamic>>> getAllStorageArea({
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
  Future<Map<String, dynamic>> getProfileData() async {
    try {
      final response = await dio.get(AppConstants.getUserProfile);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        throw data["error"];
      }

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final avatar = data["avatar"];
      Uint8List avatarBytes = Uint8List(0);

      if (avatar != null && avatar.toString().isNotEmpty) {
        try {
          final base64String = avatar.toString().split(',').last;
          avatarBytes = base64Decode(base64String);
        } catch (_) {
          avatarBytes = Uint8List(0);
        }
      }

      return {
        "avatar": avatarBytes,
        "first_name": data["first_name"],
        "last_name": data["last_name"],
        "email": data["email"],
        "user_id": data["user_id"],
        "verified": data["verified"],
        "created_at": data["created_at"],
      };
    } catch (e, s) {
      log("getUserAvatar error: $e\n$s");
      return {};
    }
  }
}
