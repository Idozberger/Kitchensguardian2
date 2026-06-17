import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class AppleSignUpUsecase implements UseCase<String, NoParams> {
  final AuthRepository authRepository;
  const AppleSignUpUsecase(this.authRepository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await authRepository.signUpWithApple();
  }
}
