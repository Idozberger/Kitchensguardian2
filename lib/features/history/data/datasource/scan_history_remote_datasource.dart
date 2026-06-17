import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

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
      final response = await dio.get("${AppConstants.getScanHistory}?page=");

      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> errBody = jsonObjectFromResponseData(
          response.data,
        );
        throw apiExceptionFrom(errBody['error']);
      }

      final Map<String, dynamic> body = jsonObjectFromResponseData(
        response.data,
      );
      final Object? history = body['history'];

      if (history == null || history is! List) {
        devLog("history is null or not a list");
        return [];
      }

      return history.map(jsonObjectFromResponseData).toList();
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }
}
