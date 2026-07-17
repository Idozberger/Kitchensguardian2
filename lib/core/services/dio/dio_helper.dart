import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:foodkitchen/app/app_router.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/services/dio/network_error_message.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioHelper {
  final Dio _dio;
  final SharedPreferences _prefs;

  DioHelper(this._dio, this._prefs) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _prefs.getString("access-token");

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            final body = options.data != null ? 'Body: ${options.data}\n' : '';
            devLog(
              '➡️ [REQUEST]\n'
              'URL: ${options.uri}\n'
              'Method: ${options.method}\n'
              'Headers: ${options.headers}\n'
              '$body',
            );
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            devLog(
              '⬅️ [RESPONSE]\n'
              'URL: ${response.requestOptions.uri}\n'
              'Status: ${response.statusCode}\n'
              'Data: ${response.data}\n',
            );
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (kDebugMode && e.response != null) {
            final res = e.response!;
            devLog(
              '⬅️ [RESPONSE ERROR]\n'
              'URL: ${e.requestOptions.uri}\n'
              'Status: ${res.statusCode}\n'
              'Data: ${res.data}\n',
            );
          }
          if (e.response != null) {
            if (e.response?.statusCode == 401) {
              final data = e.response?.data;
              final message = data is Map<String, dynamic>
                  ? (data["message"] ?? data["error"] ?? "")
                        .toString()
                        .toLowerCase()
                  : data.toString().toLowerCase();

              final isTokenExpired =
                  message.contains("token expired") ||
                  message.contains("jwt expired") ||
                  message.contains("invalid token") ||
                  message.contains("expired");

              if (isTokenExpired) {
                AppToast.show(
                  "Your session has expired. Please sign in again.",
                  ToastType.error,
                );

                await _prefs.remove("access-token");
                await _prefs.remove('kitchen_id');
                await _prefs.remove('invitation_code');
                await _prefs.remove('role');

                final context = rootNavigatorKey.currentContext;
                if (context != null) {
                  // Global navigator; null-checked after async interceptor work.
                  // ignore: use_build_context_synchronously
                  context.go(Routes.signIn);
                }

                return handler.reject(e);
              }
            }
          } else {}

          return handler.reject(e);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    return await _dio.get(path, queryParameters: query);
  }

  Future<Response> post(String path, {dynamic data, dynamic options}) async {
    return await _dio.post(
      path,
      data: data,
      options: options is Options
          ? options
          : Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response> put(String path, {dynamic data, dynamic options}) async {
    return await _dio.put(
      path,
      data: data,
      options: options is Options
          ? options
          : Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(
      path,
      data: data,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Failure> handleError(DioException e) async {
    final message = userMessageFromDioException(e);

    if (message.toLowerCase().contains("token has expired")) {
      devLog("🔒 Token expired — navigating to Sign In screen...");

      final context = rootNavigatorKey.currentContext;
      if (context != null) {
        await _prefs.remove("access-token");
        await _prefs.remove('kitchen_id');
        await _prefs.remove('invitation_code');
        await _prefs.remove('role');

        // Global navigator; null-checked after clearing prefs.
        // ignore: use_build_context_synchronously
        context.go(Routes.signIn);
      }
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
        return NetworkFailure(message);
      case DioExceptionType.badResponse:
        return ServerFailure(message);
      case DioExceptionType.unknown:
        if (e.error is SocketException) {
          return NetworkFailure(message);
        }
        return UnknownFailure(message);
    }
  }
}
