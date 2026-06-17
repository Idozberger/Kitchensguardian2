import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class CheckMissingIngredients
    implements UseCase<bool, CheckMissingIngredientsParams> {
  final PlannerRepository plannerRepository;
  const CheckMissingIngredients(this.plannerRepository);

  @override
  Future<Either<Failure, bool>> call(
    CheckMissingIngredientsParams params,
  ) async {
    return await plannerRepository.checkMissingIngredients(
      recipeId: params.recipeId,
      kitchenId: params.kitchenId,
    );
  }
}

class CheckMissingIngredientsParams {
  final String kitchenId;
  final String recipeId;
  CheckMissingIngredientsParams({
    required this.kitchenId,
    required this.recipeId,
  });
}
