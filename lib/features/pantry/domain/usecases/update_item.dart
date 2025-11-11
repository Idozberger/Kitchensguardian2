import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class UpdateItem implements UseCase<String, UpdateItemParams> {
  final PantryRepository pantryRepository;
  const UpdateItem(this.pantryRepository);

  @override
  Future<Either<Failure, String>> call(UpdateItemParams params) async {
    return await pantryRepository.updateItem(pantry: params.pantry);
  }
}

class UpdateItemParams {
  final Pantry pantry;

  UpdateItemParams({required this.pantry});
}
