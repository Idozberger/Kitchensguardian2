import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
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
    return await plannerRepository.addToFavourite(
      recipeId: params.recipeId,
      kitchenId: params.kitchenId,
    );
  }
}

class AddToFavouriteRecipeParams {
  final String recipeId;
  final String kitchenId;
  AddToFavouriteRecipeParams({required this.recipeId, required this.kitchenId});
}
