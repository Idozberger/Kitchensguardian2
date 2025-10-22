import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/pantry/data/datasource/pantry_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/model/pantry_model.dart';
import 'package:foodkitchen/features/pantry/data/model/scan_receipt_model.dart';
import 'package:foodkitchen/features/pantry/data/model/scan_receipt_item_model.dart';
import 'package:foodkitchen/core/common/entities/pantry.dart';
import 'package:foodkitchen/core/common/entities/pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/domain/repository/pantry_repository.dart';
import 'package:fpdart/fpdart.dart';

class PantryRepositoryImpl implements PantryRepository {
  final PantryRemoteDatasource pantryRemoteDatasource;
  PantryRepositoryImpl(this.pantryRemoteDatasource);
  @override
  Future<Either<Failure, String>> addItem({required Pantry pantry}) async {
    try {
      String response = await pantryRemoteDatasource.addPantryItem(
        pantryModel: PantryModel.fromEntity(pantry),
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PantryItemEntity>>> getItems({
    required String kitchenId,
  }) async {
    try {
      final response = await pantryRemoteDatasource.getPantryItems(
        kitchenId: kitchenId,
      );
      final pantryItems = (response as List)
          .map((e) => PantryItemModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(pantryItems);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ScanReceipt>> scanRecipt({
    required String filePath,
  }) async {
    try {
      final response = await pantryRemoteDatasource.scanRecipt(
        filePath: filePath,
      );

      final itemsJson = response['items'] as List<dynamic>? ?? [];

      List<ScanReceiptItemModel> items = [];

      for (var e in itemsJson) {
        items.add(
          ScanReceiptItemModel(
            name: e["name"],
            unit: e["unit"],
            amount: e["amount"],
          ),
        );
      }

      return Right(
        ScanReceiptModel(
          successMessage: response['message'] ?? '',
          items: items,
        ),
      );
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestItems({required Pantry pantry}) async {
    try {
      String response = await pantryRemoteDatasource.requestItems(
        pantryModel: PantryModel.fromEntity(pantry),
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
