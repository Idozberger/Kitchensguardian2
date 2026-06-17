import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/usecase/usecase.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class CartItems implements UseCase<String, CartItemsParams> {
  final PantryRepository pantryRepository;
  const CartItems(this.pantryRepository);

  @override
  Future<Either<Failure, String>> call(CartItemsParams params) async {
    return await pantryRepository.requestItems(pantry: params.pantry);
  }
}

class CartItemsParams {
  final Pantry pantry;

  CartItemsParams({required this.pantry});
}
