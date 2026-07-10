// ignore_for_file: unnecessary_brace_in_string_interps
// Log and error strings use `${field}` next to literals for clarity.

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class KitchenRemoteDatasource {
  Future<List<Map<String, dynamic>>> getKitchens();
  Future<String> leaveKitchen({required String kitchenId});
  Future<String> createKitchen({
    required String kitchenName,
    required UnitSystem unitSystem,
  });
  Future<String> joinKitchen({
    required String invitationCode,
    required String userId,
  });
  Future<String> removeKitchen({required String kitchenId});
  Future<String> inviteUser({required String email, required String kitchenId});
  Future<String> getUnitSystem({required String kitchenId});
  Future<String> setUnitSystem({
    required String kitchenId,
    required UnitSystem unitSystem,
  });
}

class KitchenRemoteDataSourceImpl implements KitchenRemoteDatasource {
  final DioHelper dio;
  final SharedPreferences sharedPreferences;
  KitchenRemoteDataSourceImpl(this.dio, this.sharedPreferences);
  @override
  Future<List<Map<String, dynamic>>> getKitchens() async {
    try {
      final response = await dio.get(AppConstants.kitchens);
      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        final Object? message = data['error'];
        throw apiExceptionFrom(message);
      }
      final Map<String, dynamic> root = jsonObjectFromResponseData(
        response.data,
      );
      final Object? kitchensRaw = root['kitchens'];

      if (kitchensRaw is List) {
        return kitchensRaw.map(jsonObjectFromResponseData).toList();
      } else {
        throw Exception("Invalid data");
      }
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  @override
  Future<String> createKitchen({
    required String kitchenName,
    required UnitSystem unitSystem,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.createKitchen,
        data: {
          "kitchen_name": kitchenName,
          "unit_system": unitSystemToApi(unitSystem),
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );
        throw apiExceptionFrom(data['error']);
      }

      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );
      final String kitchenId = readJsonString(data, 'kitchen_id');
      final String invitationCode = readJsonString(data, 'invitation_code');
      final String role = readJsonString(data, 'role');

      await sharedPreferences.setString('kitchen_id', kitchenId);
      await sharedPreferences.setString('invitation_code', invitationCode);
      await sharedPreferences.setString('role', role);

      return readJsonString(data, 'message');
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  Future<String> createPantry({
    required String kitchenId,
    required List<String> pantries,
  }) async {
    try {
      final pantryList = pantries.map((name) => {"pantry_name": name}).toList();

      final requestData = {"kitchen_id": kitchenId, "pantries": pantryList};

      final response = await dio.post(
        AppConstants.createPantry,
        data: requestData,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        final Object? message = data['error'];
        devPrint('⚠️ [createPantry] Error Message: $message');
        throw apiExceptionFrom(message);
      }

      final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
      return readJsonString(ok, 'message');
    } on DioException catch (e) {
      throw await dio.handleError(e);
    } catch (e, stacktrace) {
      devPrint('🧩 Stacktrace: $stacktrace');
      rethrow;
    }
  }

  @override
  Future<String> joinKitchen({
    required String invitationCode,
    required String userId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.joinKitchen,
        data: {"invitation_code": invitationCode, "user_id": userId},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );
        throw apiExceptionFrom(data['error'] ?? 'Unknown error');
      }

      final Map<String, dynamic> json = jsonObjectFromResponseData(
        response.data,
      );
      return readJsonString(json, 'message');
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  @override
  Future<String> leaveKitchen({required String kitchenId}) async {
    try {
      final response = await dio.post(
        AppConstants.leaveKitchen,
        data: {"kitchen_id": kitchenId},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        final Object? message = data['error'];
        throw apiExceptionFrom(message);
      }
      await sharedPreferences.remove('kitchen_id');
      await sharedPreferences.remove('invitation_code');
      await sharedPreferences.remove('role');
      final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
      devLog(readJsonString(ok, 'message'));

      return readJsonString(ok, 'message');
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  @override
  Future<String> removeKitchen({required String kitchenId}) async {
    try {
      final response = await dio.post(
        AppConstants.removeKitchen,
        data: {"kitchen_id": kitchenId},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        final Object? message = data['error'];
        throw apiExceptionFrom(message);
      }
      await sharedPreferences.remove('kitchen_id');
      await sharedPreferences.remove('invitation_code');
      await sharedPreferences.remove('role');

      final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
      devLog(readJsonString(ok, 'message'));

      return readJsonString(ok, 'message');
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  @override
  Future<String> inviteUser({
    required String email,
    required String kitchenId,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.inviteUser,
        data: {"kitchen_id": kitchenId, "email": email},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );

        final Object? message = data['error'];
        throw apiExceptionFrom(message);
      }
      final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
      devLog(readJsonString(ok, 'message'));

      return readJsonString(ok, 'message');
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  @override
  Future<String> getUnitSystem({required String kitchenId}) async {
    try {
      final url = "${AppConstants.getUnitSystem}?kitchen_id=$kitchenId";
      final response = await dio.get(url);

      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );
        throw apiExceptionFrom(data['error']);
      }

      final Map<String, dynamic> root = jsonObjectFromResponseData(
        response.data,
      );
      return readJsonString(root, 'unit_system', fallback: 'metric');
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }

  /// Persists the kitchen's measurement system (BRD UC-04, host only).
  /// `POST /api/kitchen/set_unit_system` -> returns the stored `unit_system`.
  @override
  Future<String> setUnitSystem({
    required String kitchenId,
    required UnitSystem unitSystem,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.setUnitSystem,
        data: {
          "kitchen_id": kitchenId,
          "unit_system": unitSystemToApi(unitSystem),
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final Map<String, dynamic> data = jsonObjectFromResponseData(
          response.data,
        );
        throw apiExceptionFrom(data['error']);
      }

      final Map<String, dynamic> root = jsonObjectFromResponseData(
        response.data,
      );
      return readJsonString(
        root,
        'unit_system',
        fallback: unitSystemToApi(unitSystem),
      );
    } on DioException catch (e) {
      throw await dio.handleError(e);
    }
  }
}
