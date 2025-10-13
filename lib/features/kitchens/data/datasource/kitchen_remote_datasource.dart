import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class KitchenRemoteDatasource {
  Future<List<Map<String, dynamic>>> getKitchens();
  Future<String> createKitchen({required String kitchenName});
  Future<String> joinKitchen({required String invitationCode});
}

class KitchenRemoteDataSourceImpl implements KitchenRemoteDatasource {
  final DioHelper dio;
  KitchenRemoteDataSourceImpl(this.dio);
  @override
  Future<List<Map<String, dynamic>>> getKitchens() async {
    try {
      final response = await dio.get(AppConstants.kitchens);
      print(response.data);
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
