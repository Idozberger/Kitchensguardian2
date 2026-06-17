import 'package:foodkitchen/core/common/domain/usecase/get_current_user.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/profile/domain/repository/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteAccount implements UseCase<String, NoParams> {
  final ProfileRepository profileRepository;
  const DeleteAccount(this.profileRepository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return profileRepository.deleteAccount();
  }
}
