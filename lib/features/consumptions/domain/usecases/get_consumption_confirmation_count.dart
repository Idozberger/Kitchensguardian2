import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/consumptions/domain/repository/consumption_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetConsumptionConfirmationCountUseCase
    implements UseCase<String, GetConsumptionConfirmationCountUseCaseParams> {
  final ConsumptionRepository consumptionRepository;
  const GetConsumptionConfirmationCountUseCase(this.consumptionRepository);

  @override
  Future<Either<Failure, String>> call(
    GetConsumptionConfirmationCountUseCaseParams params,
  ) async {
    return await consumptionRepository.getConsumptionConfirmationCount(
      kitchenId: params.kitchenId,
    );
  }
}

class GetConsumptionConfirmationCountUseCaseParams {
  final String kitchenId;

  GetConsumptionConfirmationCountUseCaseParams({required this.kitchenId});
}
