import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/consumptions/domain/entities/consumption_confirmation.dart';
import 'package:foodkitchen/features/consumptions/domain/repository/consumption_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetConsumptionConfirmationPendingUsecase
    implements
        UseCase<
          List<ConsumptionConfirmation>,
          GetConsumptionConfirmationPendingUsecaseParams
        > {
  final ConsumptionRepository consumptionRepository;
  const GetConsumptionConfirmationPendingUsecase(this.consumptionRepository);

  @override
  Future<Either<Failure, List<ConsumptionConfirmation>>> call(
    GetConsumptionConfirmationPendingUsecaseParams params,
  ) async {
    return await consumptionRepository.getConsumptionConfirmationPending(
      kitchenId: params.kitchenId,
    );
  }
}

class GetConsumptionConfirmationPendingUsecaseParams {
  final String kitchenId;

  GetConsumptionConfirmationPendingUsecaseParams({required this.kitchenId});
}
