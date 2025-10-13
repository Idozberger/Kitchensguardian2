import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/pantry/domain/entities/pantry.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PantryRepository {
  Future<Either<Failure, String>> addItem({required Pantry pantry});
  Future<Either<Failure, PantryItemEntity>> getItems({
    required String KitchenId,
  });
}
