import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/planner/domain/repository/planner_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddToFavouriteRecipe
    implements UseCase<String, AddToFavouriteRecipeParams> {
  final PlannerRepository plannerRepository;
  const AddToFavouriteRecipe(this.plannerRepository);

  @override
  Future<Either<Failure, String>> call(
    AddToFavouriteRecipeParams params,
  ) async {
    return await plannerRepository.addToFavourite(recipeId: params.recipeId);
  }
}

class AddToFavouriteRecipeParams {
  final String recipeId;

  AddToFavouriteRecipeParams({required this.recipeId});
}
