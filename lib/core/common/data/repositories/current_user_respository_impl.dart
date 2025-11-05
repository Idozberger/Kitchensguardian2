import 'package:foodkitchen/core/common/domain/entities/user.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/services/connection/connection_checker.dart';
import 'package:foodkitchen/core/common/data/datasource/current_user_remote_datasource.dart';
import 'package:foodkitchen/core/common/domain/repository/current_user_repository.dart';
import 'package:fpdart/fpdart.dart';

class CurrentUserRepositoryImpl implements CurrentUserRepository {
  final CurrentUserRemoteDatasource currentUserRemoteSources;
  final ConnectionChecker connectionChecker;

  CurrentUserRepositoryImpl(
    this.currentUserRemoteSources,
    this.connectionChecker,
  );

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final isConnected = await connectionChecker.isConnected;

      if (!isConnected) {
        return left(Failure("No Internet Connection"));
      }

      final user = await currentUserRemoteSources.getCurrentUser();
      return right(user);
    } catch (e) {
      return left(Failure("User Not Logged In"));
    }
  }
}
