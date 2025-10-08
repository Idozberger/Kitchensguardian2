import 'package:foodkitchen/core/common/entities/user.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class CurrentUserRepository {
  Future<Either<Failure, User>> getCurrentUser();
}
