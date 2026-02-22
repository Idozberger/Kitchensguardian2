import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/domain/entities/scanned_item.dart';
import 'package:fpdart/fpdart.dart';

abstract class SmartKitchenSetupRepository {
  Future<List<ScannedItemEntity>> scanKitchenImages({
    required String kitchenId,
    required String fridgeFilePath,
    required String freezerFilePath,
    required String pantryFilePath,
    required String spicesFilePath,
    required String miscFilePath,
  });
  Future<Either<Failure, String>> skipKitchenSetup({required String kitchenId});
}
