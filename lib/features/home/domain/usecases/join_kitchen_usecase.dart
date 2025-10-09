import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/usecase/usecase.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class JoinKitchen implements UseCase<String, JoinKitchenUsecaseParams> {
  final HomeRepository kitchenRepository;
  const JoinKitchen(this.kitchenRepository);

  @override
  Future<Either<Failure, String>> call(JoinKitchenUsecaseParams params) async {
    return await kitchenRepository.joinKitchen(
      invitationCode: params.invitationCode,
    );
  }
}

class JoinKitchenUsecaseParams {
  final String invitationCode;

  JoinKitchenUsecaseParams({required this.invitationCode});
}
