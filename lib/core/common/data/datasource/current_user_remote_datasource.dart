import 'package:dio/dio.dart';
import 'package:foodkitchen/core/common/domain/entities/user.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class CurrentUserRemoteDatasource {
  Future<User?> getCurrentUser();
}

class CurrentUserRemoteDataSourceImpl implements CurrentUserRemoteDatasource {
  final SharedPreferences sharedPreferences;
  final DartJwtDecoder dartJwtDecoder;
  final Dio dio;

  CurrentUserRemoteDataSourceImpl(
    this.sharedPreferences,
    this.dartJwtDecoder,
    this.dio,
  );

  Future<void> _clearAuthSession() async {
    await sharedPreferences.remove("access-token");
    await sharedPreferences.remove('kitchen_id');
    await sharedPreferences.remove('invitation_code');
    await sharedPreferences.remove('role');
    await sharedPreferences.remove("is_onboard");
  }

  @override
  Future<User?> getCurrentUser() async {
    final userToken = sharedPreferences.getString("access-token");

    if (userToken == null || userToken.isEmpty) return null;

    try {
      await dio.get<void>(AppConstants.getUserProfile);
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 422 || code == 403) {
        await _clearAuthSession();
        return null;
      }
      rethrow;
    }

    final decoded = await dartJwtDecoder.decodeTokenAndReturnUser(
      userToken: userToken,
    );

    if (decoded.isEmpty) {
      await _clearAuthSession();
      return null;
    }

    return User.fromJson(decoded);
  }
}
