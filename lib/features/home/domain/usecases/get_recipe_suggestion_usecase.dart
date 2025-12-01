import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetRecipeSuggestionUsecase
    implements UseCase<RecipeEntity, GetRecipeSuggestionUsecaseParams> {
  final HomeRepository homeRepository;
  const GetRecipeSuggestionUsecase(this.homeRepository);

  @override
  Future<Either<Failure, RecipeEntity>> call(
    GetRecipeSuggestionUsecaseParams params,
  ) async {
    return await homeRepository.getRecipeSuggestion(
      kicthenId: params.kitchenId,
    );
  }
}

class GetRecipeSuggestionUsecaseParams {
  final String kitchenId;
  GetRecipeSuggestionUsecaseParams(this.kitchenId);
}
