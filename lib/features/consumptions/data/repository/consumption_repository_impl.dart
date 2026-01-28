import 'dart:developer';

import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/consumptions/data/datasource/consumption_remote_datasource.dart';
import 'package:foodkitchen/features/consumptions/domain/entities/consumption_confirmation.dart';
import 'package:foodkitchen/features/consumptions/domain/repository/consumption_repository.dart';
import 'package:foodkitchen/features/consumptions/data/model/comsumption_confirmation_model.dart';
import 'package:fpdart/fpdart.dart';

class ConsumptionRepositoryImpl implements ConsumptionRepository {
  final ConsumptionRemoteDatasource consumptionRemoteDatasource;
  ConsumptionRepositoryImpl(this.consumptionRemoteDatasource);

  @override
  Future<Either<Failure, List<ConsumptionConfirmation>>>
  getConsumptionConfirmationPending({required String kitchenId}) async {
    try {
      final response = await consumptionRemoteDatasource
          .getConsumptionConfirmationPending(kitchenId: kitchenId);

      final List<ConsumptionConfirmation> confirmations =
          (response as List<dynamic>)
              .map((json) => ConsumptionConfirmationModel.fromJson(json))
              .toList();

      return Right(confirmations);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getConsumptionConfirmationCount({
    required String kitchenId,
  }) async {
    try {
      final response = await consumptionRemoteDatasource
          .getConsumptionConfirmationCount(kitchenId: kitchenId);

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> respondConsumptionConfirmation({
    required String confirmationId,
    required String responseText,
    required String actualQuantityRemaining,
  }) async {
    try {
      log("confirmatin id impl: $confirmationId");
      final response = await consumptionRemoteDatasource
          .respondConsumptionConfirmation(
            confirmationId: confirmationId,
            responseText: responseText,
            actualQuantityRemaining: actualQuantityRemaining,
          );

      return Right(response);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
