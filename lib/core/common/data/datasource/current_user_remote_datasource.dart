import 'package:foodkitchen/core/services/jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodkitchen/core/common/domain/entities/user.dart';

abstract interface class CurrentUserRemoteDatasource {
  Future<User?> getCurrentUser();
}

class CurrentUserRemoteDataSourceImpl implements CurrentUserRemoteDatasource {
  final SharedPreferences sharedPreferences;
  final DartJwtDecoder dartJwtDecoder;

  CurrentUserRemoteDataSourceImpl(this.sharedPreferences, this.dartJwtDecoder);

  @override
  Future<User?> getCurrentUser() async {
    final userToken = sharedPreferences.getString("access-token");

    if (userToken == null) return null;

    final decoded = await dartJwtDecoder.decodeTokenAndReturnUser(
      userToken: userToken,
    );

    return User.fromJson(decoded);
  }
}
