import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/grocery/data/datasource/grocery_remote_datasource.dart';
import 'package:foodkitchen/features/grocery/data/models/requested_items_model.dart';
import 'package:foodkitchen/features/grocery/domain/entities/requested_item.dart';
import 'package:foodkitchen/features/grocery/domain/repository/grocery_repository.dart';
import 'package:fpdart/fpdart.dart';

class GroceryRepositoryImpl implements GroceryRepository {
  final GroceryRemoteDatasource groceryRemoteDatasource;
  GroceryRepositoryImpl(this.groceryRemoteDatasource);
  @override
  Future<Either<Failure, List<RequestedItemEntity>>> getRequestedItems({
    required String kitchenId,
  }) async {
    try {
      final response = await groceryRemoteDatasource.getUserRequestedItems(
        kitchenId: kitchenId,
      );
      final data = (response as List)
          .map((e) => RequestedItemModel.fromJson(e))
          .toList();
      return Right(data);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
