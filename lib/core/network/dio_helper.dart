import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';

class DioHelper {
  final Dio _dio;

  DioHelper(this._dio) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          log(
            "➡️ [REQUEST]\nURL: ${options.uri}\nMethod: ${options.method}\nHeaders: ${options.headers}\nData: ${options.data}",
          );

          return handler.next(options);
        },
        onResponse: (response, handler) {
          logSuccess("✅ [RESPONSE]");
          logSuccess(
            "Data: ${response.data} ${response.requestOptions.uri} ${response.statusCode}",
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (e.response != null) {
            logError("Status: ${e.response?.statusCode}");
          }
          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return await _dio.get(path, queryParameters: query);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Failure handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkFailure("Connection timed out");
      case DioExceptionType.receiveTimeout:
        return NetworkFailure("Server took too long to respond");
      case DioExceptionType.badResponse:
        return ServerFailure("Internal Server Error");
      case DioExceptionType.cancel:
        return NetworkFailure("Request was cancelled");
      case DioExceptionType.unknown:
      default:
        return UnknownFailure("Unexpected error occurred");
    }
  }
}
