import 'package:foodkitchen/features/auth/domain/repository/auth_repository.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

class SendPasswordResetEmail
    implements UseCase<String, SendPasswordResetEmailParams> {
  final AuthRepository authRepository;
  const SendPasswordResetEmail(this.authRepository);

  @override
  Future<Either<Failure, String>> call(
    SendPasswordResetEmailParams params,
  ) async {
    return await authRepository.sendPasswordResetEmail(email: params.email);
  }
}

class SendPasswordResetEmailParams {
  final String email;

  SendPasswordResetEmailParams({required this.email});
}
