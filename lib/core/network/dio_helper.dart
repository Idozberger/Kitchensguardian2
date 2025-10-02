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
            logError("Status: ${e.response?.data}");
            logError("Status: ${e.response?.statusCode}");
            logError("Status: ${e.response?.statusMessage}");
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
    log("❌ DioException: $e");
    String message = "Unexpected error occurred";

    if (e.response != null && e.response?.data != null) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        message =
            data["message"] ??
            data["error"] ??
            data["detail"] ??
            data["msg"] ??
            message;
      } else if (data is String) {
        message = data;
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkFailure("Connection timed out");
      case DioExceptionType.receiveTimeout:
        return NetworkFailure("Server took too long to respond");
      case DioExceptionType.badResponse:
        return ServerFailure(message);
      case DioExceptionType.cancel:
        return NetworkFailure("Request was cancelled");
      case DioExceptionType.unknown:
      default:
        return UnknownFailure(message);
    }
  }
}
