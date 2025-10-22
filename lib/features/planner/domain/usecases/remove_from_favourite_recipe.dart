import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class RemoveFromFavouriteRecipe
    implements UseCase<String, RemoveFromFavouriteRecipeParams> {
  final PlannerRepository plannerRepository;
  const RemoveFromFavouriteRecipe(this.plannerRepository);

  @override
  Future<Either<Failure, String>> call(
    RemoveFromFavouriteRecipeParams params,
  ) async {
    return await plannerRepository.removeFromFavourite(
      recipeId: params.recipeId,
    );
  }
}

class RemoveFromFavouriteRecipeParams {
  final String recipeId;

  RemoveFromFavouriteRecipeParams({required this.recipeId});
}
