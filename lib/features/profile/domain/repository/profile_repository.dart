import 'package:foodkitchen/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, String>> setProfilePicture({required String filePath});
  Future<Either<Failure, String>> getProfilePicture();
}
