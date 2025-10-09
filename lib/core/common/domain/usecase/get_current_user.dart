import 'package:foodkitchen/core/common/entities/user.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/usecase/usecase.dart';
import 'package:foodkitchen/core/common/domain/repository/current_user_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetCurrentUserUseCase implements UseCase<User?, NoParams> {
  final CurrentUserRepository currentUserRepository;
  const GetCurrentUserUseCase(this.currentUserRepository);

  @override
  Future<Either<Failure, User?>> call(NoParams params) async {
    return await currentUserRepository.getCurrentUser();
  }
}

class NoParams {}
