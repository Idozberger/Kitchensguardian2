import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:fpdart/fpdart.dart';

class JoinKitchenUseCase implements UseCase<String, JoinKitchenUsecaseParams> {
  final KitchenRepository kitchenRepository;
  const JoinKitchenUseCase(this.kitchenRepository);

  @override
  Future<Either<Failure, String>> call(JoinKitchenUsecaseParams params) async {
    return await kitchenRepository.joinKitchen(
      invitationCode: params.invitationCode,
      userId: params.userId,
    );
  }
}

class JoinKitchenUsecaseParams {
  final String invitationCode;
  final String userId;

  JoinKitchenUsecaseParams({
    required this.invitationCode,
    required this.userId,
  });
}
