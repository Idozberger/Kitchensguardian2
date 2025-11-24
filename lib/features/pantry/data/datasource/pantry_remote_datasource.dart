import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/common/data/model/pantry_model.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';

abstract interface class PantryRemoteDatasource {
  Future<String> addPantryItem({required PantryModel pantryModel});
  Future<List<Map<String, dynamic>>> getPantryItems({
    required String kitchenId,
  });
  Future<Map<String, dynamic>> scanRecipt({required String filePath});
  Future<String> requestItems({required PantryModel pantryModel});
  Future<String> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
  Future<String> createPantry({
    required String kitchenId,
    required List<String> pantries,
  });
  Future<String> deletePantry({
    required String kitchenId,
    required String pantryId,
  });
  Future<String> deleteItem({required PantryModel pantryModel});
  Future<String> updateItem({required PantryModel pantryModel});
}

class PantryRemoteDatasourceImpl implements PantryRemoteDatasource {
  final DioHelper dio;
  final NotificationService notificationService;
  PantryRemoteDatasourceImpl({
    required this.dio,
    required this.notificationService,
  });
  @override
  Future<String> addPantryItem({required PantryModel pantryModel}) async {
    try {
      final response = await dio.post(
        AppConstants.addPantryItem,
        data: pantryModel.toJson(),
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

  Future<String> compressImage(File imageFile) async {
    var result = await FlutterImageCompress.compressWithList(
      imageFile.readAsBytesSync(),
      minWidth: 800,
      minHeight: 600,
      quality: 15,
      rotate: 0,
      inSampleSize: 1,
      autoCorrectionAngle: true,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    String base64Thumbnail = base64Encode(result);

    String dataUri = "data:image/jpeg;base64,$base64Thumbnail";

    return dataUri;
  }

  @override
  Future<List<Map<String, dynamic>>> getPantryItems({
    required String kitchenId,
  }) async {
    try {
      final url = "${AppConstants.getPantryItems}?kitchen_id=$kitchenId";

      final response = await dio.get(url);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data?["error"] ?? "Unknown error";

        throw message;
      }

      final data = response.data?["items"];

      if (data is List) {
        final parsedList = data.map((e) {
          return Map<String, dynamic>.from(e);
        }).toList();

        return parsedList;
      } else {
        throw Exception("Invalid data");
      }
    } on DioException catch (e) {
      final error = dio.handleError(e);

      throw error;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> scanRecipt({required String filePath}) async {
    try {
      final formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
          contentType: DioMediaType('image', 'jpeg'),
        ),
      });

      final response = await dio.post(AppConstants.scanRecipt, data: formData);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        final message = data["error"] ?? "Unknown error";
        throw message;
      }

      final message = response.data["message"] ?? "Unknown response";
      final items = response.data["res"]["items"];

      final parsedItems = (items is List)
          ? items.map<Map<String, dynamic>>((item) {
              final map = Map<String, dynamic>.from(item);

              if (map["thumbnail"] != null && map["thumbnail"] is String) {
                try {
                  final thumb = map["thumbnail"] as String;

                  final cleanedBase64 = thumb.contains(',')
                      ? thumb.split(',').last
                      : thumb;

                  map["thumbnail"] = base64Decode(cleanedBase64);
                } catch (e) {
                  map["thumbnail"] = Uint8List(0);
                }
              } else {}

              return map;
            }).toList()
          : [];

      return {"message": message, "items": parsedItems};
    } on DioException catch (e) {
      throw dio.handleError(e);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> requestItems({required PantryModel pantryModel}) async {
    try {
      final response = await dio.post(
        AppConstants.requestItems,
        data: pantryModel.toJson(),
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
  Future<String> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await notificationService.showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );
      return "Notfication scheduled";
    } catch (e) {
      throw e.toString();
    }
  }

  @override
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
  Future<String> deletePantry({
    required String kitchenId,
    required String pantryId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.deletePantry,
        data: {"kitchen_id": kitchenId, "pantry_id": pantryId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        logError(response.data);
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];

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
  Future<String> deleteItem({required PantryModel pantryModel}) async {
    try {
      final response = await dio.post(
        AppConstants.removeItems,
        data: {
          "item_ids": [pantryModel.items[0].itemId],
          "kitchen_id": pantryModel.kitchenId,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }

      final successMessage = response.data["message"];
      return successMessage;
    } on DioException catch (e) {
      final handledError = dio.handleError(e);

      throw handledError;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String> updateItem({required PantryModel pantryModel}) async {
    try {
      final response = await dio.post(
        AppConstants.updateKitchenItems,
        data: pantryModel.toJson(),
      );
      print("dsfasdfdsfadsfads");
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }

      final successMessage = response.data["message"];
      return successMessage;
    } on DioException catch (e) {
      final handledError = dio.handleError(e);

      throw handledError;
    } catch (e) {
      rethrow;
    }
  }
}
