import 'package:foodkitchen/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Looks up item name suggestions as the user types in "Add Item".
abstract interface class ItemSearchRepository {
  Future<Either<Failure, List<String>>> searchItems(String query);
}
