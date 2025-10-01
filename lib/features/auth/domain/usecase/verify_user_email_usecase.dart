import 'package:foodkitchen/features/auth/domain/repository/auth_repository.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

class VerifyUserEmail implements UseCase<String, VerifyUserEmailParams> {
  final AuthRepository authRepository;
  const VerifyUserEmail(this.authRepository);

  @override
  Future<Either<Failure, String>> call(VerifyUserEmailParams params) async {
    return await authRepository.verifyUserEmailWithVerificationCode(
      code: params.code,
    );
  }
}

class VerifyUserEmailParams {
  final String code;

  VerifyUserEmailParams({required this.code});
}
