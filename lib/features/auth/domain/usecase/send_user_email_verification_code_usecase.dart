import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/auth/domain/repository/auth_repository.dart';
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
      email: params.email,
    );
  }
}

class SendUserEmailVerificationCodeParams {
  final String email;
  SendUserEmailVerificationCodeParams({required this.email});
}
