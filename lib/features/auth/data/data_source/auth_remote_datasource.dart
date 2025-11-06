import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:foodkitchen/core/services/connection/connection_checker.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AuthRemoteDataSource {
  Future<String> signUpUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<String> sendUserEmailVerificationCode({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<String> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<String> sendPasswordResetEmail({required String email});
  Future<String> setUsersNewPassword({
    required String email,
    required String newPassword,
    required String verificationCode,
  });

  Future<String> verifyUserEmailWithVerificationCode({
    required String verficationCode,
    required String email,
  });
}

class AuthRemoteDatasourceImpl implements AuthRemoteDataSource {
  final DioHelper dio;
  final ConnectionChecker connectionChecker;
  final SharedPreferences sharedPreferences;
  AuthRemoteDatasourceImpl({
    required this.connectionChecker,
    required this.dio,
    required this.sharedPreferences,
  });
  @override
  Future<String> signUpUserWithEmailAndPassword({
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

      final response = await dio.post(
        AppConstants.createAccount,
        data: userModel.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> verifyUserEmailWithVerificationCode({
    required String verficationCode,
    required String email,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.verifyCode,
        data: {"verification_code": verficationCode, "email": email},
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final message = data["message"];

      return message ?? "Verification successful";
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> sendPasswordResetEmail({required String email}) async {
    try {
      final response = await dio.post(
        AppConstants.forgot,
        data: {"email": email},
      );

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final message = data["message"];

      return message ?? "Password reset code sent successfully";
    } on DioException catch (e) {
      await dio.handleError(e);
      rethrow;
    }
  }

  @override
  Future<String> setUsersNewPassword({
    required String email,
    required String newPassword,
    required String verificationCode,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.resetPassword,
        data: {
          "email": email,
          "new_password": newPassword,
          "reset_code": verificationCode,
        },
      );
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final message = data["message"];

      return message ?? "Password changed successfully";
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.login,
        data: {"email": email, "password": password},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }

      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final accessToken = data["access_token"];
      final message = data["message"];

      if (accessToken != null) {
        await sharedPreferences.setString("access-token", accessToken);
        print("Access token saved ✅");
      }

      return message ?? "Logged In Successfully";
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> sendUserEmailVerificationCode({
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

      final response = await dio.post(
        AppConstants.sendEmailVerification,
        data: userModel.toJson(),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        final data = response.data is String
            ? jsonDecode(response.data)
            : response.data;

        final message = data["error"];
        throw message;
      }
      final data = response.data is String
          ? jsonDecode(response.data)
          : response.data;

      final message = data["message"];
      return message ?? "Verification Code Sent";
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
