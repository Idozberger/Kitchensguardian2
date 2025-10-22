import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/common/entities/pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetPantryItems
    implements UseCase<List<PantryItemEntity>, GetPantryItemsParams> {
  final PantryRepository pantryRepository;
  const GetPantryItems(this.pantryRepository);

  @override
  Future<Either<Failure, List<PantryItemEntity>>> call(
    GetPantryItemsParams params,
  ) async {
    return await pantryRepository.getItems(kitchenId: params.kitchenId);
  }
}

class GetPantryItemsParams {
  final String kitchenId;

  GetPantryItemsParams({required this.kitchenId});
}
