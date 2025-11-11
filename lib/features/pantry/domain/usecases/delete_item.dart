import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteItem implements UseCase<String, DeleteItemParams> {
  final PantryRepository pantryRepository;
  const DeleteItem(this.pantryRepository);

  @override
  Future<Either<Failure, String>> call(DeleteItemParams params) async {
    return await pantryRepository.deleteItem(pantry: params.pantry);
  }
}

class DeleteItemParams {
  final Pantry pantry;

  DeleteItemParams({required this.pantry});
}
