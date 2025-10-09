import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class KitchenRemoteDatasource {
  Future<Map<String, dynamic>> getKitchens();
}

class KitchenRemoteDataSourceImpl implements KitchenRemoteDatasource {
  final DioHelper dio;
  KitchenRemoteDataSourceImpl(this.dio);
  @override
  Future<Map<String, dynamic>> getKitchens() async {
    try {
      final response = await dio.get(AppConstants.kitchens);
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      final kitchens = data["kitchens"];
      return kitchens;
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
