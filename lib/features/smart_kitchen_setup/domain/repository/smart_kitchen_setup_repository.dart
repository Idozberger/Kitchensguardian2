import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/entities/kitchen_setup_scan_result.dart';
import 'package:fpdart/fpdart.dart';

abstract class SmartKitchenSetupRepository {
  Future<Either<Failure, KitchenSetupScanResult>> scanKitchenImages({
    required String kitchenId,
    required List<String> fridgeFilePaths,
    required List<String> freezerFilePaths,
    required List<String> pantryFilePaths,
    required List<String> spicesFilePaths,
    required List<String> miscFilePaths,
  });

  Future<Either<Failure, String>> finalizeSetup({
    required String sessionId,
    required List<Map<String, dynamic>> items,
  });

  Future<Either<Failure, String>> skipKitchenSetup({required String kitchenId});
}
