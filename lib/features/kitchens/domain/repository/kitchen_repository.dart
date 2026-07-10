import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/kitchens/data/model/kitchen.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class KitchenRepository {
  Future<Either<Failure, List<KitchenModel>>> getKitchens();
  Future<Either<Failure, String>> createKitchen({
    required String kitchenName,
    required UnitSystem unitSystem,
  });
  Future<Either<Failure, String>> joinKitchen({
    required String invitationCode,
    required String userId,
  });
  Future<Either<Failure, String>> leaveKitchen({required String kitchenId});
  Future<Either<Failure, String>> removeKitchen({required String kitchenId});
  Future<Either<Failure, String>> inviteUser({
    required String kitchenId,
    required String email,
  });
  Future<Either<Failure, String>> getUnitSystem({required String kitchenId});
  Future<Either<Failure, String>> setUnitSystem({
    required String kitchenId,
    required UnitSystem unitSystem,
  });
}
