import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class DashboardRemoteDatasource {
  Future<List<Map<String, dynamic>>> getKitchenMembers({
    required String kitchenId,
  });
  Future<String> makeCohost({
    required String kitchenId,
    required String memberId,
  });
  Future<String> kickMember({
    required String kitchenId,
    required String memberId,
  });
  Future<List<Map<String, dynamic>>> getConsumptionConfirmationPending({
    required String kitchenId,
  });
}

class DashboardRemoteDatasourceImpl implements DashboardRemoteDatasource {
  final DioHelper dio;
  DashboardRemoteDatasourceImpl(this.dio);
  @override
  Future<List<Map<String, dynamic>>> getKitchenMembers({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.getMembers}?kitchen_id=$kitchenId",
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final data = response.data["members"];

      if (data is List) {
        debugPrint("Kitchen members: ${data.map((member) => member)}");
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception("Invalid data");
      }
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> kickMember({
    required String kitchenId,
    required String memberId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.kickMember,
        data: {"kitchen_id": kitchenId, "member_id": memberId},
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
  Future<String> makeCohost({
    required String kitchenId,
    required String memberId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.makeCohost,
        data: {"kitchen_id": kitchenId, "member_id": memberId},
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
  Future<List<Map<String, dynamic>>> getConsumptionConfirmationPending({
    required String kitchenId,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.consumptionConfirmationPending}?kitchen_id=$kitchenId",
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      return List<Map<String, dynamic>>.from(data['confirmations']);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
