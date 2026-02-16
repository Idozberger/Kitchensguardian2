// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class KitchenRemoteDatasource {
  Future<List<Map<String, dynamic>>> getKitchens();
  Future<String> leaveKitchen({required String kitchenId});
  Future<String> createKitchen({required String kitchenName});
  Future<String> joinKitchen({
    required String invitationCode,
    required String userId,
  });
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
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
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

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        throw data["error"];
      }

      final data = response.data;
      final kitchenId = data["kitchen_id"];
      final invitationCode = data["invitation_code"];
      final role = data["role"];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('kitchen_id', kitchenId.toString());
      await prefs.setString('invitation_code', invitationCode.toString());
      await prefs.setString('role', role.toString());

      await createPantry(
        kitchenId: kitchenId.toString(),
        pantries: const ["Fridge", "Freezer", "Pantry", "Spices"],
      );

      return data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  Future<String> createPantry({
    required String kitchenId,
    required List<String> pantries,
  }) async {
    try {
      final pantryList = pantries.map((name) => {"pantry_name": name}).toList();

      final requestData = {"kitchen_id": kitchenId, "pantries": pantryList};

      final response = await dio.post(
        AppConstants.createPantry,
        data: requestData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        debugPrint('⚠️ [createPantry] Error Message: $message');
        throw message;
      }

      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    } catch (e, stacktrace) {
      debugPrint('🧩 Stacktrace: $stacktrace');
      rethrow;
    }
  }

  @override
  Future<String> joinKitchen({
    required String invitationCode,
    required String userId,
  }) async {
    final url = Uri.parse("${AppConstants.baseUrl}${AppConstants.joinKitchen}");

    final body = jsonEncode({
      "invitation_code": invitationCode,
      "user_id": userId,
    });

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json["message"];
    } else {
      final json = jsonDecode(response.body);
      throw json["error"] ?? "Unknown error";
    }
  }

  @override
  Future<String> leaveKitchen({required String kitchenId}) async {
    try {
      final response = await dio.post(
        AppConstants.leaveKitchen,
        data: {"kitchen_id": kitchenId},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
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
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
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
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      log(response.data["message"]);

      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
