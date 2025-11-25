import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/kitchens/data/model/kitchen.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class KitchenRepository {
  Future<Either<Failure, List<KitchenModel>>> getKitchens();
  Future<Either<Failure, String>> createKitchen({required String kitchenName});
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
}
