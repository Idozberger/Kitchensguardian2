import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SetUserNewPassword implements UseCase<String, SetUserNewPasswordParams> {
  final AuthRepository authRepository;
  const SetUserNewPassword(this.authRepository);

  @override
  Future<Either<Failure, String>> call(SetUserNewPasswordParams params) async {
    return await authRepository.setUsersNewPassword(
      email: params.email,
      newPassword: params.newPassword,
      verificationCode: params.verificationCode,
    );
  }
}

class SetUserNewPasswordParams {
  final String email;
  final String verificationCode;
  final String newPassword;

  SetUserNewPasswordParams({
    required this.email,
    required this.newPassword,
    required this.verificationCode,
  });
}
