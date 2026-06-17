import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignIn implements UseCase<String, UserSignInParams> {
  final AuthRepository authRepository;
  const UserSignIn(this.authRepository);

  @override
  Future<Either<Failure, String>> call(UserSignInParams params) async {
    return await authRepository.signInUserWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class UserSignInParams {
  final String email;
  final String password;

  UserSignInParams({required this.email, required this.password});
}
