import 'package:foodkitchen/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class HomeRepository {
  Future<Either<Failure, String>> createKitchen({required String kitchenName});
  Future<Either<Failure, String>> joinKitchen({required String invitationCode});
}
