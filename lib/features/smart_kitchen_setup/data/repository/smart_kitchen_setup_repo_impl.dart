import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/data/datasource/smart_kitchen_setup_datasource.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/entities/scanned_item.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/domain/repository/smart_kitchen_setup_repository.dart';
import 'package:fpdart/fpdart.dart';
import '../models/scanned_item_model.dart';

class SmartKitchenSetupRepositoryImpl implements SmartKitchenSetupRepository {
  final SmartKitchenSetupDatasource smartKitchenSetupDatasource;

  SmartKitchenSetupRepositoryImpl({required this.smartKitchenSetupDatasource});

  @override
  Future<List<ScannedItemEntity>> scanKitchenImages({
    required String kitchenId,
    required List<String> fridgeFilePaths,
    required List<String> freezerFilePaths,
    required List<String> pantryFilePaths,
    required List<String> spicesFilePaths,
    required List<String> miscFilePaths,
  }) async {
    final rawData = await smartKitchenSetupDatasource.getScanResult(
      kitchenId: kitchenId,
      fridgeFilePaths: fridgeFilePaths,
      freezerFilePaths: freezerFilePaths,
      pantryFilePaths: pantryFilePaths,
      spicesFilePaths: spicesFilePaths,
      miscFilePaths: miscFilePaths,
    );

    return rawData.map<ScannedItemEntity>((json) {
      final model = ScannedItemModel.fromJson(json);
      return model.toEntity();
    }).toList();
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
