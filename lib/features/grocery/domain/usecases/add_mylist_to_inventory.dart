import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/grocery/domain/repository/grocery_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddMylistToInventory
    implements UseCase<List<RequestedItemEntity>, AddMylistToInventoryParams> {
  final GroceryRepository groceryRepository;
  const AddMylistToInventory(this.groceryRepository);

  @override
  Future<Either<Failure, List<RequestedItemEntity>>> call(
    AddMylistToInventoryParams params,
  ) async {
    return await groceryRepository.addMyListToKitchenInventory(
      kitchenId: params.kitchenId,
    );
  }
}

class AddMylistToInventoryParams {
  final String kitchenId;

  AddMylistToInventoryParams({required this.kitchenId});
}
