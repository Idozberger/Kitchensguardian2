import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_remote_datasource_impl_part.dart';

abstract interface class HomeRemoteDataSource {
  Future<Map<String, dynamic>> createKitchen({
    required String kitchenName,
    required UnitSystem unitSystem,
  });
  Future<String> respondToItemRequest({
    required String action,
    required String rejectReason,
    required String requestId,
  });
  Future<Map<String, List<Map<String, dynamic>>>> getPantriesItems({
    required String kitchenId,
  });
  Future<List<Map<String, dynamic>>> getWeeklyPlans({
    required String kitchenId,
  });
  Future<Map<String, dynamic>> getRecipeSuggestion({required String kitchenId});
  Future<List<Map<String, dynamic>>> getAllRequestedItems({
    required String kitchenId,
  });
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final SharedPreferences sharedPreferences;
  final DioHelper dio;
  HomeRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  @override
  Future<Map<String, dynamic>> createKitchen({
    required String kitchenName,
    required UnitSystem unitSystem,
  }) => _homeImplCreateKitchen(
    this,
    kitchenName: kitchenName,
    unitSystem: unitSystem,
  );

  @override
  Future<Map<String, List<Map<String, dynamic>>>> getPantriesItems({
    required String kitchenId,
  }) => _homeImplGetPantriesItems(this, kitchenId: kitchenId);

  @override
  Future<List<Map<String, dynamic>>> getWeeklyPlans({
    required String kitchenId,
  }) => _homeImplGetWeeklyPlans(this, kitchenId: kitchenId);

  @override
  Future<Map<String, dynamic>> getRecipeSuggestion({
    required String kitchenId,
  }) => _homeImplGetRecipeSuggestion(this, kitchenId: kitchenId);

  @override
  Future<List<Map<String, dynamic>>> getAllRequestedItems({
    required String kitchenId,
  }) => _homeImplGetAllRequestedItems(this, kitchenId: kitchenId);

  @override
  Future<String> respondToItemRequest({
    required String action,
    required String rejectReason,
    required String requestId,
  }) => _homeImplRespondToItemRequest(
    this,
    action: action,
    rejectReason: rejectReason,
    requestId: requestId,
  );
}
