import 'package:foodkitchen/core/common/data/datasource/common_remote_datasource.dart';
import 'package:foodkitchen/core/common/domain/entities/meal_type_entity.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/home/data/datasource/home_remote_datasource.dart';
import 'package:foodkitchen/features/home/data/models/kitchen_model.dart';
import 'package:foodkitchen/features/home/data/models/pantry_data_model.dart';
import 'package:foodkitchen/features/home/domain/entities/kitchen.dart';
import 'package:foodkitchen/features/home/domain/entities/pantry_data.dart';
import 'package:foodkitchen/features/home/domain/repository/home_repository.dart';
import 'package:fpdart/fpdart.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource homeRemoteDataSource;
  final CommonRemoteDatasource commonRemoteDatasource;
  HomeRepositoryImpl({
    required this.homeRemoteDataSource,
    required this.commonRemoteDatasource,
  });
  @override
  Future<Either<Failure, Kitchen>> createKitchen({
    required String kitchenName,
  }) async {
    try {
      final response = await homeRemoteDataSource.createKitchen(
        kitchenName: kitchenName,
      );
      final kitchenModel = KitchenModel(
        invitationCode: response["invitation_code"],
        kitchenId: response["kitchen_id"],
        message: response["message"],
      );

      return right(kitchenModel);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> joinKitchen({
    required String invitationCode,
  }) async {
    try {
      final response = await homeRemoteDataSource.joinKitchen(
        invitationCode: invitationCode,
      );
      return right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PantriesDataEntity>> getItems({
    required String kitchenId,
  }) async {
    try {
      final response = await homeRemoteDataSource.getPantriesItems(
        kitchenId: kitchenId,
      );
      final pantryData = PantriesDataModel.fromJson(response);

      return Right(pantryData);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MealTypeEntity>>> getAllWeeklyPlans() async {
    try {
      final response = await homeRemoteDataSource.getWeeklyPlans();

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
