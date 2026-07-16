import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/entities/scanned_item.dart';
import 'package:fpdart/fpdart.dart';

abstract class SmartKitchenSetupRepository {
  Future<Either<Failure, List<ScannedItemEntity>>> scanKitchenImages({
    required String kitchenId,
    required List<String> fridgeFilePaths,
    required List<String> freezerFilePaths,
    required List<String> pantryFilePaths,
    required List<String> spicesFilePaths,
    required List<String> miscFilePaths,
  });
  Future<Either<Failure, String>> skipKitchenSetup({required String kitchenId});
}
