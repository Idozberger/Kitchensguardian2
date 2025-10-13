import 'package:dio/dio.dart';
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

      final data = response.data["members"];

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
  Future<String> kickMember({
    required String kitchenId,
    required String memberId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.kickMember,
        data: {"kitchen_id": kitchenId, "member_id": memberId},
      );
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
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
