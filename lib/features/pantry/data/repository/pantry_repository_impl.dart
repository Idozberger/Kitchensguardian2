import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/pantry/data/datasource/pantry_remote_datasource.dart';
import 'package:foodkitchen/features/pantry/data/model/pantry_model.dart';
import 'package:foodkitchen/features/pantry/domain/entities/pantry.dart';
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
  Future<Either<Failure, PantryItemEntity>> getItems({
    required String KitchenId,
  }) async {
    try {
      final response = await pantryRemoteDatasource.getPantryItems(
        kitchenId: KitchenId,
      );

      return Right(
        PantryItemEntity(group: "", name: '', quantity: 5, unit: ''),
      );
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
