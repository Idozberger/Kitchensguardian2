import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/kitchens/data/model/kitchen.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class KitchenRepository {
  Future<Either<Failure, List<KitchenModel>>> getKitchens();
}
