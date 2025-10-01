import 'package:dio/dio.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:foodkitchen/core/global/functions/const.dart';
import 'package:foodkitchen/core/network/dio_helper.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUpUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<UserModel> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserModel> sendPasswordResetVerificationCode({required String email});
  Future<UserModel> setUsersNewPassword({
    required String email,
    required String newPassword,
  });

  Future<UserModel> verifyUserEmailWithVerificationCode({required String code});
}

class AuthRemoteDatasourceImpl implements AuthRemoteDataSource {
  final DioHelper dio;
  AuthRemoteDatasourceImpl(this.dio);
  @override
  Future<UserModel> signUpUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      UserModel dummyUser = UserModel(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      final response = await dio.post(
        AppConstants.createAccount,
        data: dummyUser.toJson(),
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<UserModel> verifyUserEmailWithVerificationCode({
    required String code,
  }) async {
    try {
      UserModel dummyUser = UserModel(
        firstName: "firstName",
        lastName: "lastName",
        email: "email",
      );

      final response = await dio.post(AppConstants.createAccount, data: code);

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<UserModel> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.createAccount,
        data: {"email": email, "password": password},
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<UserModel> sendPasswordResetVerificationCode({
    required String email,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.resetPassword,
        data: {"email": email},
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }

  @override
  Future<UserModel> setUsersNewPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final response = await dio.post(
        AppConstants.setNewPassword,
        data: {"email": email, "new_password": newPassword},
      );

      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw dio.handleError(e);
    }
  }
}
