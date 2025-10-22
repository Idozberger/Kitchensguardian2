import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';

abstract interface class ScanHistoryRemoteDatasource {
  Future<List<Map<String, dynamic>>> getScanHistory({
    required String pageNumber,
  });
}

class ScanHistoryRemoteDatasourceImpl implements ScanHistoryRemoteDatasource {
  final DioHelper dio;
  ScanHistoryRemoteDatasourceImpl(this.dio);
  @override
  Future<List<Map<String, dynamic>>> getScanHistory({
    required String pageNumber,
  }) async {
    try {
      final response = await dio.get(
        "${AppConstants.getScanHistory}?page=$pageNumber",
      );

      final data = response.data["history"];

      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        throw Exception("Invalid data");
      }
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
