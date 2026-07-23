import 'package:foodkitchen/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, String>> signUpUserWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<Either<Failure, String>> sendUserEmailVerificationCode({
    required String email,
  });
  Future<Either<Failure, String>> signInUserWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<Either<Failure, String>> sendPasswordResetEmail({
    required String email,
  });
  Future<Either<Failure, String>> setUsersNewPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  });
  Future<Either<Failure, String>> verifyUserEmailWithVerificationCode({
    required String verificationCode,
    required String email,
  });
  Future<Either<Failure, String>> signInWithGoogle();

  Future<Either<Failure, String>> signUpWithGoogle();

  Future<Either<Failure, String>> signInWithApple();

  Future<Either<Failure, String>> signUpWithApple();
}
