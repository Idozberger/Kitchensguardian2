import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeletePlanRemoteDb implements UseCase<String, DeletePlanRemoteDbParams> {
  final PlannerRepository plannerRepository;
  const DeletePlanRemoteDb(this.plannerRepository);

  @override
  Future<Either<Failure, String>> call(DeletePlanRemoteDbParams params) async {
    return await plannerRepository.deletePlanFromRemoteDb(
      mealPlanId: params.mealPlanId,
      kitchenId: params.kitchenId,
      date: params.date,
    );
  }
}

class DeletePlanRemoteDbParams {
  final String mealPlanId;
  final String kitchenId;
  final String date;
  DeletePlanRemoteDbParams({
    required this.mealPlanId,
    required this.date,
    required this.kitchenId,
  });
}
