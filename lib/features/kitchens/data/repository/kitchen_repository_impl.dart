import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/kitchens/data/datasource/kitchen_remote_datasource.dart';
import 'package:foodkitchen/features/kitchens/data/model/kitchen.dart';
import 'package:foodkitchen/features/kitchens/domain/repository/kitchen_repository.dart';
import 'package:fpdart/fpdart.dart';

class KitchenRepositoryImpl implements KitchenRepository {
  final KitchenRemoteDatasource kitchenRemoteDataSource;
  KitchenRepositoryImpl(this.kitchenRemoteDataSource);
  @override
  Future<Either<Failure, List<KitchenModel>>> getKitchens() async {
    try {
      final response = await kitchenRemoteDataSource.getKitchens();

      final kitchens = (response as List)
          .map((e) => KitchenModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return Right(kitchens);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> createKitchen({
    required String kitchenName,
    required UnitSystem unitSystem,
  }) async {
    try {
      final response = await kitchenRemoteDataSource.createKitchen(
        kitchenName: kitchenName,
        unitSystem: unitSystem,
      );
      return right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> joinKitchen({
    required String invitationCode,
    required String userId,
  }) async {
    try {
      final response = await kitchenRemoteDataSource.joinKitchen(
        invitationCode: invitationCode,
        userId: userId,
      );
      return right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> leaveKitchen({
    required String kitchenId,
  }) async {
    try {
      final response = await kitchenRemoteDataSource.leaveKitchen(
        kitchenId: kitchenId,
      );
      return right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> removeKitchen({
    required String kitchenId,
  }) async {
    try {
      final response = await kitchenRemoteDataSource.removeKitchen(
        kitchenId: kitchenId,
      );
      return right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> inviteUser({
    required String kitchenId,
    required String email,
  }) async {
    try {
      final response = await kitchenRemoteDataSource.inviteUser(
        kitchenId: kitchenId,
        email: email,
      );
      return right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> getUnitSystem({
    required String kitchenId,
  }) async {
    try {
      final response = await kitchenRemoteDataSource.getUnitSystem(
        kitchenId: kitchenId,
      );
      return right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }

  @override
  Future<Either<Failure, String>> setUnitSystem({
    required String kitchenId,
    required UnitSystem unitSystem,
  }) async {
    try {
      final response = await kitchenRemoteDataSource.setUnitSystem(
        kitchenId: kitchenId,
        unitSystem: unitSystem,
      );
      return right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }
}
