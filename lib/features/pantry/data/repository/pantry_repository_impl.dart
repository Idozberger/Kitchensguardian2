import 'dart:developer';

import 'package:foodkitchen/core/common/data/datasource/common_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/model/pantries_model.dart';
import 'package:foodkitchen/core/common/domain/entities/pantries_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
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
  final CommonRemoteDatasource commonRemoteDatasource;
  PantryRepositoryImpl({
    required this.pantryRemoteDatasource,
    required this.commonRemoteDatasource,
  });

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
        final expireDate = e['expiry_date'].toString();
        final thumbnail = e['thumbnail'];

        print(
          "Item parsed - name: $name, unit: $unit, amount: $amount, expireDate: $expireDate",
        );

        items.add(
          ScanReceiptItemModel(
            name: name,
            unit: unit,
            amount: amount.isEmpty ? "1" : amount,
            expireDate: expireDate,
            thumbnail: thumbnail,
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

  @override
  Future<Either<Failure, String>> createPantry({
    required String kitchenId,
    required List<String> pantries,
  }) async {
    try {
      final response = await pantryRemoteDatasource.createPantry(
        kitchenId: kitchenId,
        pantries: pantries,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e, stack) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PantriesCommonEntity>>> getAllStorageArea({
    required String kitchenId,
  }) async {
    try {
      final response = await commonRemoteDatasource.getAllStorageArea(
        kitchenId: kitchenId,
      );

      final pantries = response
          .map((json) => PantriesCommonModel.fromJson(json))
          .toList();

      return Right(pantries);
    } on Failure catch (f) {
      return Left(f);
    } catch (e, stack) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deletePantry({
    required String kitchenId,
    required String pantryId,
  }) async {
    try {
      final response = await pantryRemoteDatasource.deletePantry(
        kitchenId: kitchenId,
        pantryId: pantryId,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e, stack) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> cartItems({required Pantry pantry}) async {
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
  Future<Either<Failure, String>> deleteItem({required Pantry pantry}) async {
    try {
      String response = await pantryRemoteDatasource.deleteItem(
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
  Future<Either<Failure, String>> updateItem({required Pantry pantry}) async {
    try {
      String response = await pantryRemoteDatasource.updateItem(
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
