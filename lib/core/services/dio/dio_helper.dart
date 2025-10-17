import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:foodkitchen/app/app_router.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';

class DioHelper {
  final Dio _dio;

  DioHelper(this._dio) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("access-token");

          ///[dio.options.headers]
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          log(
            "➡️ [REQUEST]\n"
            "URL: ${options.uri}\n"
            "Method: ${options.method}\n"
            "Headers: ${options.headers}\n"
            "Data: ${options.data}",
          );

          return handler.next(options);
        },
        onResponse: (response, handler) {
          logSuccess("✅ [RESPONSE]");
          logSuccess(
            "Data: ${response.data} "
            "${response.requestOptions.uri} "
            "${response.statusCode}",
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response != null) {
            logError("❌ [ERROR RESPONSE]");
            logError("Data: ${e.response?.data}");

            logError("Status: ${e.response?.statusCode}");
            logError("Message: ${e.response?.statusMessage}");
            if (e.response?.statusCode == 401) {
              AppToast.show(
                "Session expired. Please log in again.",
                ToastType.error,
              );

              final context = rootNavigatorKey.currentContext;
              if (context != null) {
                context.go('/login');
              }

              return handler.reject(e);
            }
          } else {
            logError("❌ [DIO ERROR] ${e.message}");
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
