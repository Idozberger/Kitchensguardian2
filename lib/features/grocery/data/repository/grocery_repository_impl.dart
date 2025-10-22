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

  @override
  Future<Either<Failure, List<RequestedItemEntity>>> updateBucketType({
    required String kitchenId,
    required List<String> itemsIds,
    required String bucketType,
  }) async {
    try {
      final response = await groceryRemoteDatasource.updateBucketType(
        kitchenId: kitchenId,
        itemsIds: itemsIds,
        bucketType: bucketType,
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

  @override
  Future<Either<Failure, List<RequestedItemEntity>>>
  addMyListToKitchenInventory({required String kitchenId}) async {
    try {
      final response = await groceryRemoteDatasource
          .addMyListToKitchenInventory(kitchenId: kitchenId);
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

  @override
  Future<Either<Failure, List<RequestedItemEntity>>> getAiGeneratedItems({
    required String kitchenId,
  }) async {
    try {
      final response = await groceryRemoteDatasource.getAiGeneratedItems(
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

  @override
  Future<Either<Failure, List<RequestedItemEntity>>> deleteKitchenItems({
    required String kitchenId,
    required List<String> itemsIds,
  }) async {
    try {
      final response = await groceryRemoteDatasource.deleteKitchenItems(
        kitchenId: kitchenId,
        itemsIds: itemsIds,
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

  @override
  Future<Either<Failure, List<RequestedItemEntity>>> addCustomItems({
    required String kitchenId,
    required String name,
    required String quantity,
    required String unit,
    required String bucketType,
  }) async {
    try {
      final response = await groceryRemoteDatasource.addCustomItems(
        kitchenId: kitchenId,
        name: name,
        quantity: quantity,
        unit: unit,
        bucketType: bucketType,
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
