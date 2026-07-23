import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/env.dart';
import 'package:foodkitchen/core/global/functions/api_endpoints.dart';
import 'package:foodkitchen/core/services/connection/connection_checker.dart';
import 'package:foodkitchen/core/services/dio/dio_helper.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/auth/data/model/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'auth_remote_datasource_impl_part.dart';
part 'auth_remote_datasource_impl_part2.dart';
part 'auth_remote_datasource_impl_part3.dart';

abstract interface class AuthRemoteDataSource {
  Future<String> signUpUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<String> sendUserEmailVerificationCode({required String email});
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
  Future<String> signInWithGoogle();

  Future<String> signUpWithGoogle();

  Future<String> signInWithApple();

  Future<String> signUpWithApple();
}

class AuthRemoteDatasourceImpl implements AuthRemoteDataSource {
  final DioHelper dio;
  final ConnectionChecker connectionChecker;
  final UserCubit userCubit;
  final SharedPreferences sharedPreferences;
  AuthRemoteDatasourceImpl({
    required this.connectionChecker,
    required this.dio,
    required this.sharedPreferences,
    required this.userCubit,
  });

  @override
  Future<String> signUpUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) => _authImplSignUpUserWithEmailAndPassword(
    this,
    firstName: firstName,
    lastName: lastName,
    email: email,
    password: password,
  );

  @override
  Future<String> verifyUserEmailWithVerificationCode({
    required String verficationCode,
    required String email,
  }) => _authImplVerifyUserEmailWithVerificationCode(
    this,
    verficationCode: verficationCode,
    email: email,
  );

  @override
  Future<String> sendPasswordResetEmail({required String email}) =>
      _authImplSendPasswordResetEmail(this, email: email);

  @override
  Future<String> setUsersNewPassword({
    required String email,
    required String newPassword,
    required String verificationCode,
  }) => _authImplSetUsersNewPassword(
    this,
    email: email,
    newPassword: newPassword,
    verificationCode: verificationCode,
  );

  @override
  Future<String> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  }) => _authImplSignInUserWithEmailAndPassword(
    this,
    email: email,
    password: password,
  );

  @override
  Future<String> sendUserEmailVerificationCode({required String email}) =>
      _authImplSendUserEmailVerificationCode(this, email: email);

  @override
  Future<String> signInWithGoogle() => _authImplSignInWithGoogle(this);

  @override
  Future<String> signUpWithGoogle() => _authImplSignUpWithGoogle(this);

  @override
  Future<String> signInWithApple() => _authImplSignInWithApple(this);

  @override
  Future<String> signUpWithApple() => _authImplSignUpWithApple(this);

  Future<void> signOut() => _authImplSignOut(this);
}
