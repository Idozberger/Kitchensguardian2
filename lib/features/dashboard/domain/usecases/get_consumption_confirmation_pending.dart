import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/dashboard/domain/entities/consumption_confirmation.dart';
import 'package:foodkitchen/features/dashboard/domain/repository/dashboard_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetConsumptionConfirmationPendingUsecase
    implements
        UseCase<
          List<ConsumptionConfirmation>,
          GetConsumptionConfirmationPendingUsecaseParams
        > {
  final DashboardRepository dashboardRepository;
  const GetConsumptionConfirmationPendingUsecase(this.dashboardRepository);

  @override
  Future<Either<Failure, List<ConsumptionConfirmation>>> call(
    GetConsumptionConfirmationPendingUsecaseParams params,
  ) async {
    return await dashboardRepository.getConsumptionConfirmationPending(
      kitchenId: params.kitchenId,
    );
  }
}

class GetConsumptionConfirmationPendingUsecaseParams {
  final String kitchenId;

  GetConsumptionConfirmationPendingUsecaseParams({required this.kitchenId});
}
