import 'dart:developer';

import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/features/auth/data/data_source/auth_remote_datasource.dart';
import 'package:foodkitchen/features/auth/domain/repository/auth_repository.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  AuthRepositoryImpl(this.authRemoteDataSource);
  @override
  Future<Either<Failure, String>> signUpUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      String response = await authRemoteDataSource
          .signUpUserWithEmailAndPassword(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
          );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyUserEmailWithVerificationCode({
    required String verificationCode,
    required String email,
  }) async {
    try {
      String response = await authRemoteDataSource
          .verifyUserEmailWithVerificationCode(
            verficationCode: verificationCode,
            email: email,
          );
      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      final response = await authRemoteDataSource.sendPasswordResetEmail(
        email: email,
      );
      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> setUsersNewPassword({
    required String email,
    required String newPassword,
    required String verificationCode,
  }) async {
    try {
      final response = await authRemoteDataSource.setUsersNewPassword(
        email: email,
        newPassword: newPassword,
        verificationCode: verificationCode,
      );
      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await authRemoteDataSource
          .signInUserWithEmailAndPassword(email: email, password: password);
      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> sendUserEmailVerificationCode({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      String response = await authRemoteDataSource
          .sendUserEmailVerificationCode(
            firstName: firstName,
            lastName: lastName,
            email: email,
            password: password,
          );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
