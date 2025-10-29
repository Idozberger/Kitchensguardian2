import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/profile/domain/repository/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class SetProfilePicture implements UseCase<String, SetProfilePictureParams> {
  final ProfileRepository profileRepository;
  const SetProfilePicture(this.profileRepository);

  @override
  Future<Either<Failure, String>> call(SetProfilePictureParams params) async {
    return await profileRepository.setProfilePicture(filePath: params.filePath);
  }
}

class SetProfilePictureParams {
  final String filePath;

  SetProfilePictureParams({required this.filePath});
}
