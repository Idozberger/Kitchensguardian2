import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/features/grocery/domain/entities/requested_item.dart';
import 'package:foodkitchen/features/grocery/domain/repository/grocery_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddCustomItem
    implements UseCase<List<RequestedItemEntity>, AddCustomItemParams> {
  final GroceryRepository groceryRepository;
  const AddCustomItem(this.groceryRepository);

  @override
  Future<Either<Failure, List<RequestedItemEntity>>> call(
    AddCustomItemParams params,
  ) async {
    return await groceryRepository.addCustomItems(
      kitchenId: params.kitchenId,
      name: params.name,
      quantity: params.quantity,
      unit: params.unit,
      bucketType: params.bucketType,
    );
  }
}

class AddCustomItemParams {
  final String kitchenId;
  final String name;
  final String quantity;
  final String unit;
  final String bucketType;

  AddCustomItemParams({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.bucketType,
    required this.kitchenId,
  });
}
