part of 'package:foodkitchen/features/auth/data/data_source/auth_remote_datasource.dart';

Future<String> _authImplSignUpUserWithEmailAndPassword(
  AuthRemoteDatasourceImpl ds, {
  required String firstName,
  required String lastName,
  required String email,
  required String password,
}) async {
  try {
    UserModel userModel = UserModel(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    final response = await ds.dio.post(
      AppConstants.createAccount,
      data: userModel.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    final Map<String, dynamic> ok = jsonObjectFromResponseData(response.data);
    return readJsonString(ok, 'message');
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<String> _authImplVerifyUserEmailWithVerificationCode(
  AuthRemoteDatasourceImpl ds, {
  required String verficationCode,
  required String email,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.verifyCode,
      data: {"verification_code": verficationCode, "email": email},
    );

    final Map<String, dynamic> data = jsonObjectFromResponseData(response.data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    await ds.sharedPreferences.setString(
      "access-token",
      readJsonString(data, 'access_token'),
    );
    final String message = readJsonString(data, 'message');

    return message.isEmpty ? "Verification successful" : message;
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<String> _authImplSendPasswordResetEmail(
  AuthRemoteDatasourceImpl ds, {
  required String email,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.forgot,
      data: {"email": email},
    );

    final Map<String, dynamic> data = jsonObjectFromResponseData(response.data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    final String message = readJsonString(data, 'message');

    return message.isEmpty ? "Password reset code sent successfully" : message;
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<String> _authImplSetUsersNewPassword(
  AuthRemoteDatasourceImpl ds, {
  required String email,
  required String newPassword,
  required String verificationCode,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.resetPassword,
      data: {
        "email": email,
        "new_password": newPassword,
        "reset_code": verificationCode,
      },
    );
    final Map<String, dynamic> data = jsonObjectFromResponseData(response.data);
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    final String message = readJsonString(data, 'message');

    return message.isEmpty ? "Password changed successfully" : message;
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}

Future<String> _authImplSignInUserWithEmailAndPassword(
  AuthRemoteDatasourceImpl ds, {
  required String email,
  required String password,
}) async {
  try {
    final response = await ds.dio.post(
      AppConstants.login,
      data: {"email": email, "password": password},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message =
          data['error'] ?? data['message'] ?? 'Login failed';
      throw apiExceptionFrom(message);
    }

    final Map<String, dynamic> data = jsonObjectFromResponseData(response.data);

    final String accessToken = readJsonString(data, 'access_token');
    final String message = readJsonString(
      data,
      'message',
      fallback: 'Logged in successfully',
    );

    if (accessToken.isEmpty) {
      throw apiExceptionFrom('Invalid response: Access token is missing');
    }

    await ds.sharedPreferences.setString("access-token", accessToken);

    await Future<void>.delayed(const Duration(milliseconds: 100));

    final savedToken = ds.sharedPreferences.getString("access-token");
    if (savedToken == null || savedToken != accessToken) {
      devPrint("Token save failed! Retrying...");
      await ds.sharedPreferences.setString("access-token", accessToken);
    }

    devPrint("Access token saved & verified successfully");

    return message;
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  } catch (e) {
    devPrint("Unexpected login error: $e");
    rethrow;
  }
}

Future<String> _authImplSendUserEmailVerificationCode(
  AuthRemoteDatasourceImpl ds, {
  required String firstName,
  required String lastName,
  required String email,
  required String password,
}) async {
  try {
    UserModel userModel = UserModel(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    final response = await ds.dio.post(
      AppConstants.sendEmailVerification,
      data: userModel.toJson(),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Map<String, dynamic> data = jsonObjectFromResponseData(
        response.data,
      );

      final Object? message = data['error'];
      throw apiExceptionFrom(message);
    }
    final Map<String, dynamic> data = jsonObjectFromResponseData(response.data);

    final String message = readJsonString(data, 'message');
    return message.isEmpty ? "Verification Code Sent" : message;
  } on DioException catch (e) {
    throw await ds.dio.handleError(e);
  }
}
