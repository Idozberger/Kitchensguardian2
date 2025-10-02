import 'package:dio/dio.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/network/dio_helper.dart';

abstract interface class AuthRemoteDataSource {
  Future<String> signUpUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<String> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<String> sendPasswordResetVerificationCode({required String email});
  Future<String> setUsersNewPassword({
    required String email,
    required String newPassword,
  });

  Future<String> verifyUserEmailWithVerificationCode({required String code});
}

class AuthRemoteDatasourceImpl implements AuthRemoteDataSource {
  final DioHelper dio;
  AuthRemoteDatasourceImpl(this.dio);
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

      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> verifyUserEmailWithVerificationCode({
    required String code,
  }) async {
    try {
      final response = await dio.post(AppConstants.createAccount, data: code);

      return response.data.message;
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
        AppConstants.createAccount,
        data: {"email": email, "password": password},
      );

      return response.data["message"];
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> sendPasswordResetVerificationCode({
    required String email,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.resetPassword,
        data: {"email": email},
      );

      return response.data.message;
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<String> setUsersNewPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.setNewPassword,
        data: {"email": email, "new_password": newPassword},
      );

      return response.data.message;
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
