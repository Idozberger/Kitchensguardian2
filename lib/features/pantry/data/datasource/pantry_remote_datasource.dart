import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:foodkitchen/core/common/data/model/pantry_model.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/services/notifications/flutter_local_notifications_service.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

part 'pantry_remote_datasource_impl_part.dart';
part 'pantry_remote_datasource_impl_part2.dart';

abstract interface class PantryRemoteDatasource {
  Future<String> addPantryItem({required PantryModel pantryModel});
  Future<String> addRequestItem({required PantryModel pantryModel});
  Future<List<Map<String, dynamic>>> getPantryItems({
    required String kitchenId,
  });

  Future<Map<String, dynamic>> scanRecipt({
    required String filePath,
    required String currency,
    required String country,
    required String kitchenId,
  });
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

  Future<String> compressImage(File imageFile) =>
      _pantryImplCompressImage(this, imageFile);

  @override
  Future<String> addPantryItem({required PantryModel pantryModel}) =>
      _pantryImplAddPantryItem(this, pantryModel: pantryModel);

  @override
  Future<List<Map<String, dynamic>>> getPantryItems({
    required String kitchenId,
  }) => _pantryImplGetPantryItems(this, kitchenId: kitchenId);

  @override
  Future<Map<String, dynamic>> scanRecipt({
    required String filePath,
    required String currency,
    required String country,
    required String kitchenId,
  }) => _pantryImplScanRecipt(
    this,
    filePath: filePath,
    currency: currency,
    country: country,
    kitchenId: kitchenId,
  );

  @override
  Future<String> requestItems({required PantryModel pantryModel}) =>
      _pantryImplRequestItems(this, pantryModel: pantryModel);

  @override
  Future<String> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) => _pantryImplShowNotification(
    this,
    id: id,
    title: title,
    body: body,
    payload: payload,
  );

  @override
  Future<String> createPantry({
    required String kitchenId,
    required List<String> pantries,
  }) => _pantryImplCreatePantry(this, kitchenId: kitchenId, pantries: pantries);

  @override
  Future<String> deletePantry({
    required String kitchenId,
    required String pantryId,
  }) => _pantryImplDeletePantry(this, kitchenId: kitchenId, pantryId: pantryId);

  @override
  Future<String> deleteItem({required PantryModel pantryModel}) =>
      _pantryImplDeleteItem(this, pantryModel: pantryModel);

  @override
  Future<String> updateItem({required PantryModel pantryModel}) =>
      _pantryImplUpdateItem(this, pantryModel: pantryModel);

  @override
  Future<String> addRequestItem({required PantryModel pantryModel}) =>
      _pantryImplAddRequestItem(this, pantryModel: pantryModel);
}
