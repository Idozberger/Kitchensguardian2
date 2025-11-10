import 'package:foodkitchen/core/common/domain/entities/pantries_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class PantryRepository {
  Future<Either<Failure, String>> addItem({required Pantry pantry});
  Future<Either<Failure, List<PantryItemEntity>>> getItems({
    required String kitchenId,
  });
  Future<Either<Failure, ScanReceiptEntity>> scanRecipt({
    required String filePath,
  });
  Future<Either<Failure, String>> requestItems({required Pantry pantry});
  Future<Either<Failure, String>> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });
  Future<Either<Failure, String>> createPantry({
    required String kitchenId,
    required List<String> pantries,
  });
  Future<Either<Failure, List<PantriesCommonEntity>>> getAllStorageArea({
    required String kitchenId,
  });
  Future<Either<Failure, String>> deletePantry({
    required String kitchenId,
    required String pantryId,
  });
}
