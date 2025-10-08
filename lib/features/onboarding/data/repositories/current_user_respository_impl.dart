import 'package:foodkitchen/core/common/entities/user.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/onboarding/domain/repository/current_user_repository.dart';
import 'package:fpdart/src/either.dart';

class CurrentUserRespositoryImpl implements CurrentUserRepository {
  @override
  Future<Either<Failure, User>> getCurrentUser() {
    // TODO: implement getCurrentUser
    throw UnimplementedError();
  }
}
