import 'package:dio/dio.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/services/jwt_decoder/jwt_decoder.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Registers **process-wide** dependencies: local persistence, JWT helper, and HTTP.
///
/// Call once from [initDependencies] after [SharedPreferences.getInstance] completes.
/// Feature modules should depend on these types via [GetIt], not construct duplicates.
void registerCoreSharedServices(
  GetIt sl, {
  required SharedPreferences sharedPreferences,
  required DartJwtDecoder jwtDecoder,
}) {
  sl
    ..registerSingleton<SharedPreferences>(sharedPreferences)
    ..registerSingleton<DartJwtDecoder>(jwtDecoder)
    ..registerLazySingleton<Dio>(
      () => Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 30),
        ),
      ),
    )
    ..registerLazySingleton<DioHelper>(
      () => DioHelper(sl<Dio>(), sl<SharedPreferences>()),
    );
}
