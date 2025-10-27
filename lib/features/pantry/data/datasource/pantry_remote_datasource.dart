import 'package:dio/dio.dart';
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
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPantryItems({
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

      final message = response.data["message"] ?? "Unknown response";
      final items = response.data["res"]["items"];

      return {
        "message": message,
        "items": (items is List)
            ? items.map((e) => Map<String, dynamic>.from(e)).toList()
            : [],
      };
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> requestItems({required PantryModel pantryModel}) async {
    try {
      Map<String, dynamic> data = {
        "kitchen_id": pantryModel.kitchenId,
        "name": pantryModel.items[0].name,
        "quantity": pantryModel.items[0].quantity.toString(),
        "unit": pantryModel.items[0].unit,
      };
      logError(data);
      final response = await dio.post(AppConstants.requestItems, data: data);
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
}
