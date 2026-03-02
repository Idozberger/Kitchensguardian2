import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddPantryRequestItem
    implements UseCase<String, AddPantryRequestItemParams> {
  final PantryRepository pantryRepository;
  const AddPantryRequestItem(this.pantryRepository);

  @override
  Future<Either<Failure, String>> call(
    AddPantryRequestItemParams params,
  ) async {
    return await pantryRepository.addPantryRequestItem(pantry: params.pantry);
  }
}

class AddPantryRequestItemParams {
  final Pantry pantry;

  AddPantryRequestItemParams({required this.pantry});
}
