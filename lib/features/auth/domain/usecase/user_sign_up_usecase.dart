import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserSignUp implements UseCase<String, UserSignUpParams> {
  final AuthRepository authRepository;
  const UserSignUp(this.authRepository);

  @override
  Future<Either<Failure, String>> call(UserSignUpParams params) async {
    return await authRepository.signUpUserWithEmailAndPassword(
      firstName: params.firstName,
      lastName: params.lastName,
      email: params.email,
      password: params.password,
    );
  }
}

class UserSignUpParams {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  UserSignUpParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
  });
}
