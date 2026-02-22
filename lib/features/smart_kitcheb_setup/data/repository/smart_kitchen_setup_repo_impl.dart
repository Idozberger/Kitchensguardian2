import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/data/datasource/smart_kitchen_setup_datasource.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/domain/entities/scanned_item.dart';
import 'package:foodkitchen/features/smart_kitcheb_setup/domain/repository/smart_kitchen_setup_repository.dart';
import 'package:fpdart/fpdart.dart';
import '../models/scanned_item_model.dart';

class SmartKitchenSetupRepositoryImpl implements SmartKitchenSetupRepository {
  final SmartKitchenSetupDatasource smartKitchenSetupDatasource;

  SmartKitchenSetupRepositoryImpl({required this.smartKitchenSetupDatasource});

  @override
  Future<List<ScannedItemEntity>> scanKitchenImages({
    required String kitchenId,
    required String fridgeFilePath,
    required String freezerFilePath,
    required String pantryFilePath,
    required String spicesFilePath,
    required String miscFilePath,
  }) async {
    final rawData = await smartKitchenSetupDatasource.getScanResult(
      kitchenId: kitchenId,
      fridgeFilePath: fridgeFilePath,
      freezerFilePath: freezerFilePath,
      pantryFilePath: pantryFilePath,
      spicesFilePath: spicesFilePath,
      miscFilePath: miscFilePath,
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
      return Left(UnknownFailure(e.toString()));
    }
  }
}
