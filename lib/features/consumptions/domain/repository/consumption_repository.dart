import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/consumptions/domain/entities/consumption_confirmation.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class ConsumptionRepository {
  Future<Either<Failure, List<ConsumptionConfirmation>>>
  getConsumptionConfirmationPending({required String kitchenId});
  Future<Either<Failure, String>> getConsumptionConfirmationCount({
    required String kitchenId,
  });
  Future<Either<Failure, String>> respondConsumptionConfirmation({
    required String confirmationId,
    required String responseText,
    required String actualQuantityRemaining,
  });
}
