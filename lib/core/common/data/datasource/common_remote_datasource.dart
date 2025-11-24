import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class CommonRemoteDatasource {
  Future<List<Map<String, dynamic>>> getAllStorageArea({
    required String kitchenId,
  });
  Future<Uint8List> getUserAvatar();
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
  Future<Uint8List> getUserAvatar() async {
    try {
      final response = await dio.get(AppConstants.getUserProfile);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }

      final avatar = response.data["avatar"];

      if (avatar == null || avatar.isEmpty) {
        return Uint8List(0);
      }

      final base64String = avatar.split(',').last;

      try {
        return base64Decode(base64String);
      } catch (_) {
        return Uint8List(0);
      }
    } catch (_) {
      return Uint8List(0);
    }
  }
}
