import 'package:foodkitchen/core/common/data/datasource/profile_local_datasource.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/profile/domain/repository/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, String>> setProfilePicture({
    required String filePath,
  }) async {
    try {
      final result = await localDataSource.setProfileImage(filePath: filePath);
      return Right(result);
    } catch (e) {
      return Left(Failure('Failed to save profile picture'));
    }
  }

  @override
  Future<Either<Failure, String>> getProfilePicture() async {
    try {
      String? result = await localDataSource.getProfileImage();
      if (result == null || result.isEmpty) {
        return Left(Failure('No profile picture found'));
      }
      return Right(result);
    } catch (e) {
      return Left(Failure('Failed to get profile picture'));
    }
  }
}
