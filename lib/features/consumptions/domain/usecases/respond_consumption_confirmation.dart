import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/consumptions/domain/repository/consumption_repository.dart';
import 'package:fpdart/fpdart.dart';

class RespondConsumptionConfirmationUseCase
    implements UseCase<String, RespondConsumptionConfirmationUseCaseParams> {
  final ConsumptionRepository consumptionRepository;
  const RespondConsumptionConfirmationUseCase(this.consumptionRepository);

  @override
  Future<Either<Failure, String>> call(
    RespondConsumptionConfirmationUseCaseParams params,
  ) async {
    return await consumptionRepository.respondConsumptionConfirmation(
      confirmationId: params.confirmationId,
      responseText: params.responseText,
      actualQuantityRemaining: params.actualQuantityRemaining,
    );
  }
}

class RespondConsumptionConfirmationUseCaseParams {
  final String confirmationId;
  final String responseText;
  final String actualQuantityRemaining;

  RespondConsumptionConfirmationUseCaseParams({
    required this.confirmationId,
    required this.responseText,
    required this.actualQuantityRemaining,
  });
}
