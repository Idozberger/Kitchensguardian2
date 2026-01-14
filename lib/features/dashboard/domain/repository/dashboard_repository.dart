import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/dashboard/domain/entities/consumption_confirmation.dart';
import 'package:foodkitchen/features/dashboard/domain/entities/member.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class DashboardRepository {
  Future<Either<Failure, List<Member>>> getKichenMembers({
    required String kitchenId,
  });
  Future<Either<Failure, String>> makeCohost({
    required String kitchenId,
    required String memberId,
  });
  Future<Either<Failure, String>> kickMember({
    required String kitchenId,
    required String memberId,
  });
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
