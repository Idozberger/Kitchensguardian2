import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class CreatePantryUsecase
    implements UseCase<String, CreatePantryUsecaseParams> {
  final PantryRepository pantryRepository;
  const CreatePantryUsecase(this.pantryRepository);

  @override
  Future<Either<Failure, String>> call(CreatePantryUsecaseParams params) async {
    return await pantryRepository.createPantry(
      kitchenId: params.kitchenId,
      pantries: params.pantries,
    );
  }
}

class CreatePantryUsecaseParams {
  final String kitchenId;
  final List<String> pantries;

  CreatePantryUsecaseParams({required this.kitchenId, required this.pantries});
}
