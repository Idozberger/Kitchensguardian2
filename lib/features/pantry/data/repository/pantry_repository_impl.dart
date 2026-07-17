import 'dart:convert';
import 'dart:typed_data';

import 'package:foodkitchen/core/common/data/datasource/common_remote_datasource.dart';
import 'package:foodkitchen/core/common/data/model/pantries_model.dart';
import 'package:foodkitchen/core/common/data/model/pantry_model.dart';
import 'package:foodkitchen/core/common/domain/entities/pantries_entity.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/logging/app_logger.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:foodkitchen/features/pantry/data/datasource/pantry_remote_datasource.dart';
import 'package:foodkitchen/features/pantry/data/model/scan_receipt_item_model.dart';
import 'package:foodkitchen/features/pantry/data/model/scan_receipt_model.dart';
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
      return Left(unknownFailureFrom(e));
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
          .map(
            (Object? e) =>
                PantryItemModel.fromJson(jsonObjectFromResponseData(e)),
          )
          .toList();

      return Right(pantryItems);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }

  @override
  Future<Either<Failure, ScanReceiptEntity>> scanRecipt({
    required String filePath,
    required String currency,
    required String country,
    required String kitchenId,
  }) async {
    try {
      final response = await pantryRemoteDatasource.scanRecipt(
        filePath: filePath,
        currency: currency,
        country: country,
        kitchenId: kitchenId,
      );
      devPrint("response result: ${response["items"]}");
      final itemsJson = response['items'] as List<dynamic>? ?? [];

      List<ScanReceiptItemModel> items = [];

      for (final Object? raw in itemsJson) {
        try {
          final Map<String, dynamic> e = jsonObjectFromResponseData(raw);
          final name = readJsonString(e, 'name');
          final unit = readJsonString(e, 'unit', fallback: 'unit');
          final amount = readJsonString(e, 'amount');
          final group = readJsonString(e, 'recommended_storage');
          final expireDate = readJsonString(e, 'expiry_date');
          final needsReview = readJsonBool(e, 'needs_review');
          final estimatedWeightGrams = (e['estimated_weight_grams'] as num?)
              ?.toDouble();
          final weightBasis = e['weight_basis'] as String?;
          // Keep the raw base64 payload as-is - decoding happens lazily at
          // render time (PantryItem.displayBytes) so a large receipt doesn't
          // decode every item's image up front.
          final Object? thumbRaw = e['thumbnail'];
          final String thumbnailBase64 = thumbRaw is String
              ? thumbRaw
              : thumbRaw is Uint8List
              ? base64Encode(thumbRaw)
              : '';

          devPrint(
            "Item parsed - name: $name, unit: $unit, quantity: $amount, expireDate: $expireDate",
          );

          items.add(
            ScanReceiptItemModel(
              group: group,
              name: name,
              unit: unit,
              amount: amount.isEmpty ? "1" : amount,
              expireDate: expireDate,
              thumbnail: thumbnailBase64,
              needsReview: needsReview,
              estimatedWeightGrams: estimatedWeightGrams,
              weightBasis: weightBasis,
            ),
          );
        } catch (itemError, itemStack) {
          // One malformed OCR line shouldn't drop every other correctly-parsed item.
          AppLogger.recordNonFatal(
            itemError,
            itemStack,
            reason: 'scan_receipt_item_parse',
          );
          devPrint("Skipped malformed scanned item: $itemError");
        }
      }

      final receipt = ScanReceiptModel(
        successMessage: response['message'] as String? ?? '',
        items: items,
      );

      devPrint("ScanReceiptModel created: $receipt");

      return Right(receipt);
    } on Failure catch (f) {
      devPrint("Failure caught: ${f.message}");
      return Left(f);
    } catch (e) {
      devPrint("Unknown error: $e");
      return Left(unknownFailureFrom(e));
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
      return Left(unknownFailureFrom(e));
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
      return Left(unknownFailureFrom(e));
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
    } catch (e) {
      return Left(unknownFailureFrom(e));
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

      final pantries = response.map(PantriesCommonModel.fromJson).toList();

      return Right(pantries);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
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
    } catch (e) {
      return Left(unknownFailureFrom(e));
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
      return Left(unknownFailureFrom(e));
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
      return Left(unknownFailureFrom(e));
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
      return Left(unknownFailureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> addPantryRequestItem({
    required Pantry pantry,
  }) async {
    try {
      String response = await pantryRemoteDatasource.addRequestItem(
        pantryModel: PantryModel.fromEntity(pantry),
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }
}
