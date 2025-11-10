import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeletePantry implements UseCase<String, DeletePantryParams> {
  final PantryRepository pantryRepository;
  const DeletePantry(this.pantryRepository);

  @override
  Future<Either<Failure, String>> call(DeletePantryParams params) async {
    return await pantryRepository.deletePantry(
      kitchenId: params.kitchenId,
      pantryId: params.pantryId,
    );
  }
}

class DeletePantryParams {
  final String kitchenId;
  final String pantryId;

  DeletePantryParams({required this.kitchenId, required this.pantryId});
}
