import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/profile/domain/repository/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class EditProfile implements UseCase<String, EditProfileParams> {
  final ProfileRepository profileRepository;
  const EditProfile(this.profileRepository);

  @override
  Future<Either<Failure, String>> call(EditProfileParams params) async {
    return await profileRepository.editProfile(
      firstName: params.firstName,
      lastName: params.lastName,
    );
  }
}

class EditProfileParams {
  final String firstName;
  final String lastName;
  EditProfileParams({required this.firstName, required this.lastName});
}
