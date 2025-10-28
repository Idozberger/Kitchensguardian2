import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class MarkRecipeFinished implements UseCase<String, MarkRecipeFinishedParams> {
  final PlannerRepository plannerRepository;
  const MarkRecipeFinished(this.plannerRepository);

  @override
  Future<Either<Failure, String>> call(MarkRecipeFinishedParams params) async {
    return await plannerRepository.markRecipeFinished(
      kitchenId: params.kitchenId,
      recipeId: params.recipeId,
    );
  }
}

class MarkRecipeFinishedParams {
  final String kitchenId;
  final String recipeId;

  MarkRecipeFinishedParams({required this.kitchenId, required this.recipeId});
}
