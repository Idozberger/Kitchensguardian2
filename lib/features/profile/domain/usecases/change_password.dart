import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/profile/domain/repository/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class ChangePassword implements UseCase<String, ChangePasswordParams> {
  final ProfileRepository profileRepository;
  const ChangePassword(this.profileRepository);

  @override
  Future<Either<Failure, String>> call(ChangePasswordParams params) async {
    return await profileRepository.chnagePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;
  ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}
