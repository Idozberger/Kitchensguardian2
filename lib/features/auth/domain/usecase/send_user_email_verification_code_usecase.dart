import 'package:foodkitchen/features/auth/domain/repository/auth_repository.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

class SendUserEmailVerificationCode
    implements UseCase<String, SendUserEmailVerificationCodeParams> {
  final AuthRepository authRepository;
  const SendUserEmailVerificationCode(this.authRepository);

  @override
  Future<Either<Failure, String>> call(
    SendUserEmailVerificationCodeParams params,
  ) async {
    return await authRepository.sendUserEmailVerificationCode(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      password: params.password,
    );
  }
}

class SendUserEmailVerificationCodeParams {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  SendUserEmailVerificationCodeParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
}
