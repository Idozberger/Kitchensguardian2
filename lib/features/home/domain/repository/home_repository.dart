import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/home/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/home/domain/entities/pantries_items.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, Kitchen>> createKitchen({required String kitchenName});
  Future<Either<Failure, String>> joinKitchen({required String invitationCode});
  Future<Either<Failure, List<PantriesItemsEntity>>> getItems({
    required String kitchenId,
  });
}
