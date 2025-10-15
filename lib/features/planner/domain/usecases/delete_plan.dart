import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/usecase/usecase.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeletePlan implements UseCase<String, DeletePlanParams> {
  final PlannerRepository plannerRepository;
  const DeletePlan(this.plannerRepository);

  @override
  Future<Either<Failure, String>> call(DeletePlanParams params) async {
    return await plannerRepository.deletePlan(id: params.dateString);
  }
}

class DeletePlanParams {
  final String dateString;
  DeletePlanParams(this.dateString);
}
