import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/core/logging/app_logger.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/data/datasource/smart_kitchen_setup_datasource.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/entities/kitchen_setup_scan_result.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/entities/scanned_item.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/repository/smart_kitchen_setup_repository.dart';
import 'package:fpdart/fpdart.dart';
import '../models/scanned_item_model.dart';

class SmartKitchenSetupRepositoryImpl implements SmartKitchenSetupRepository {
  final SmartKitchenSetupDatasource smartKitchenSetupDatasource;

  SmartKitchenSetupRepositoryImpl({required this.smartKitchenSetupDatasource});

  @override
  Future<Either<Failure, KitchenSetupScanResult>> scanKitchenImages({
    required String kitchenId,
    required List<String> fridgeFilePaths,
    required List<String> freezerFilePaths,
    required List<String> pantryFilePaths,
    required List<String> spicesFilePaths,
    required List<String> miscFilePaths,
  }) async {
    try {
      final rawData = await smartKitchenSetupDatasource.getScanResult(
        kitchenId: kitchenId,
        fridgeFilePaths: fridgeFilePaths,
        freezerFilePaths: freezerFilePaths,
        pantryFilePaths: pantryFilePaths,
        spicesFilePaths: spicesFilePaths,
        miscFilePaths: miscFilePaths,
      );

      final items = <ScannedItemEntity>[];
      for (final json in rawData.items) {
        try {
          items.add(ScannedItemModel.fromJson(json).toEntity());
        } catch (itemError, itemStack) {
          AppLogger.recordNonFatal(
            itemError,
            itemStack,
            reason: 'scan_kitchen_item_parse',
          );
        }
      }

      return Right(
        KitchenSetupScanResult(sessionId: rawData.sessionId, items: items),
      );
    } on Failure catch (f) {
      return Left(f);
    } catch (e, st) {
      return Left(unknownFailureFrom(e, st));
    }
  }

  @override
  Future<Either<Failure, String>> finalizeSetup({
    required String sessionId,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      await smartKitchenSetupDatasource.editSetup(
        sessionId: sessionId,
        items: items,
      );
      final result = await smartKitchenSetupDatasource.confirmSetup(
        sessionId: sessionId,
      );
      return Right(
        'Added ${result.addedCount} item(s), updated ${result.updatedCount}',
      );
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> skipKitchenSetup({
    required String kitchenId,
  }) async {
    try {
      String response = await smartKitchenSetupDatasource.skipKitchenSetup(
        kitchenId: kitchenId,
      );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }
}
