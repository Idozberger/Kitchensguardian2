import 'package:foodkitchen/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, String>> setProfilePicture({required String filePath});
  Future<Either<Failure, String>> getProfilePicture();
  Future<Either<Failure, String>> editProfile({
    required String firstName,
    required String lastName,
    required String thumbnail,
  });
  Future<Either<Failure, String>> chnagePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<Either<Failure, String>> deleteAccount();
}
