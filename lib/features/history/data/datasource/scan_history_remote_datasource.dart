import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
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
      final response = await dio.get("${AppConstants.getScanHistory}?page=");

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;
        throw data["error"];
      }

      final history = response.data["history"];

      if (history == null || history is! List) {
        log("history is null or not a list");
        return [];
      }

      return List<Map<String, dynamic>>.from(history);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
