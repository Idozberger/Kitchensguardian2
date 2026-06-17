import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/grocery/domain/repository/grocery_repository.dart';
import 'package:fpdart/fpdart.dart';

class EditGroceryListItem
    implements UseCase<String, EditGroceryListItemParams> {
  final GroceryRepository groceryRepository;
  const EditGroceryListItem(this.groceryRepository);

  @override
  Future<Either<Failure, String>> call(EditGroceryListItemParams params) async {
    return await groceryRepository.editGroceryListItem(
      kitchenId: params.kitchenId,
      itemId: params.itemId,
      name: params.name,
      quantity: params.quantity,
      unit: params.unit,
    );
  }
}

class EditGroceryListItemParams {
  final String kitchenId;
  final String itemId;
  final String name;
  final String quantity;
  final String unit;

  EditGroceryListItemParams({
    required this.itemId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.kitchenId,
  });
}
