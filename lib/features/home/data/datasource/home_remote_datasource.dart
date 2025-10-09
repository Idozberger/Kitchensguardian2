import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class HomeRemoteDataSource {
  Future<String> createKitchen({required String kitchenName});
  Future<String> joinKitchen({required String invitationCode});
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final DioHelper dio;
  HomeRemoteDataSourceImpl(this.dio);
  @override
  Future<String> createKitchen({required String kitchenName}) async {
    try {
      final response = await dio.post(
        AppConstants.createKitchen,
        data: {"kitchen_name": kitchenName},
      );
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> joinKitchen({required String invitationCode}) async {
    try {
      final response = await dio.post(
        AppConstants.joinKitchen,
        data: {"invitation_code": invitationCode},
      );
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
