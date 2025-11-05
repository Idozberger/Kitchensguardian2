import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/features/pantry/data/datasource/pantry_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/model/pantry_model.dart';
import 'package:foodkitchen/features/pantry/data/model/scan_receipt_model.dart';
import 'package:foodkitchen/features/pantry/data/model/scan_receipt_item_model.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
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
  Future<Either<Failure, ScanReceiptEntity>> scanRecipt({
    required String filePath,
  }) async {
    try {
      final response = await pantryRemoteDatasource.scanRecipt(
        filePath: filePath,
      );

      final itemsJson = response['items'] as List<dynamic>? ?? [];

      List<ScanReceiptItemModel> items = [];

      for (var e in itemsJson) {
        final name = e['name'] as String? ?? '';
        final unit = e['unit'] as String? ?? 'Unit';
        final amount = e['amount'].toString();

        print("Item parsed - name: $name, unit: $unit, amount: $amount");

        items.add(
          ScanReceiptItemModel(
            name: name,
            unit: unit,
            amount: amount.isEmpty ? "1" : amount,
          ),
        );
      }

      final receipt = ScanReceiptModel(
        successMessage: response['message'] as String? ?? '',
        items: items,
      );

      print("ScanReceiptModel created: ${receipt.toString()}");

      return Right(receipt);
    } on Failure catch (f) {
      print("Failure caught: ${f.message}");
      return Left(f);
    } catch (e) {
      print("Unknown error: $e");
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

  @override
  Future<Either<Failure, String>> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      String response = await pantryRemoteDatasource.showNotification(
        id: id,
        title: title,
        body: body,
        payload: payload,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
