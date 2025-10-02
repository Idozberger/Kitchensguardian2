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
    required String code,
  }) async {
    try {
      final userModel = await authRemoteDataSource
          .verifyUserEmailWithVerificationCode(code: code);
      return Right("User Verfied Successfully");
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
      final userModel = await authRemoteDataSource
          .signInUserWithEmailAndPassword(email: email, password: password);
      return Right("Success");
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> sendPasswordResetVerificationCode({
    required String email,
  }) async {
    try {
      final userModel = await authRemoteDataSource
          .sendPasswordResetVerificationCode(email: email);
      return Right("Success");
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
  }) async {
    try {
      final userModel = await authRemoteDataSource.setUsersNewPassword(
        email: email,
        newPassword: newPassword,
      );
      return Right("Success");
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
