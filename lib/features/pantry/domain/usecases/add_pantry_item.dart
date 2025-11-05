import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddPantryItem implements UseCase<String, AddPantryItemParams> {
  final PantryRepository pantryRepository;
  const AddPantryItem(this.pantryRepository);

  @override
  Future<Either<Failure, String>> call(AddPantryItemParams params) async {
    return await pantryRepository.addItem(pantry: params.pantry);
  }
}

class AddPantryItemParams {
  final Pantry pantry;

  AddPantryItemParams({required this.pantry});
}
