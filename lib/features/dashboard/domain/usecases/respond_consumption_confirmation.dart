import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

class RespondConsumptionConfirmationUseCase
    implements UseCase<String, RespondConsumptionConfirmationUseCaseParams> {
  final DashboardRepository dashboardRepository;
  const RespondConsumptionConfirmationUseCase(this.dashboardRepository);

  @override
  Future<Either<Failure, String>> call(
    RespondConsumptionConfirmationUseCaseParams params,
  ) async {
    return await dashboardRepository.respondConsumptionConfirmation(
      confirmationId: '',
      responseText: '',
      actualQuantityRemaining: '',
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
