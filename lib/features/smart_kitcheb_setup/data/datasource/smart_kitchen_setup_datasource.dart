import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract class SmartKitchenSetupDatasource {
  Future<List<Map<String, dynamic>>> getScanResult({
    required String kitchenId,
    required String fridgeFilePath,
    required String freezerFilePath,
    required String pantryFilePath,
    required String spicesFilePath,
    required String miscFilePath,
  });
  Future<String> skipKitchenSetup({required String kitchenId});
}

class SmartKitchenSetupDatasourceImpl implements SmartKitchenSetupDatasource {
  final DioHelper dio;

  SmartKitchenSetupDatasourceImpl({required this.dio});

  @override
  Future<List<Map<String, dynamic>>> getScanResult({
    required String kitchenId,
    required String fridgeFilePath,
    required String freezerFilePath,
    required String pantryFilePath,
    required String spicesFilePath,
    required String miscFilePath,
  }) async {
    try {
      final Map<String, dynamic> fields = {'kitchen_id': kitchenId};

      await _addImageField(fields, 'image_fridge', fridgeFilePath);
      await _addImageField(fields, 'image_freezer', freezerFilePath);
      await _addImageField(fields, 'image_pantry', pantryFilePath);
      await _addImageField(fields, 'image_spices', spicesFilePath);
      await _addImageField(fields, 'image_miscellaneous', miscFilePath);

      final formData = FormData.fromMap(fields);

      final response = await dio.post(
        AppConstants.kitchenSetupScan,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        throw data?['error'] ?? 'Unknown error';
      }

      final decoded = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      if (decoded["auto_confirmed"] is List) {
        return List<Map<String, dynamic>>.from(decoded["auto_confirmed"]);
      }

      throw 'Unexpected response format — check logs for actual shape';
    } on DioException catch (e) {
      throw dio.handleError(e);
    } catch (e, stacktrace) {
      debugPrint('Stacktrace: $stacktrace');
      rethrow;
    }
  }

  Future<void> _addImageField(
    Map<String, dynamic> fields,
    String key,
    String path,
  ) async {
    if (path.isEmpty) return;
    final cleanPath = path.replaceFirst('file://', '');
    fields[key] = await MultipartFile.fromFile(
      cleanPath,
      filename: cleanPath.split('/').last,
    );
  }

  @override
  Future<String> skipKitchenSetup({required String kitchenId}) async {
    try {
      final pantryList = const [
        "Fridge",
        "Freezer",
        "Pantry",
        "Spices",
      ].map((name) => {"pantry_name": name}).toList();

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
        debugPrint('[createPantry] Error Message: $message');
        throw message;
      }

      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    } catch (e, stacktrace) {
      debugPrint('Stacktrace: $stacktrace');
      rethrow;
    }
  }
}
