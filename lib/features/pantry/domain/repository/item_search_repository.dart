import 'package:foodkitchen/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// One suggestion row from the shared ingredient catalog.
class ItemSearchResult {
  final String id;
  final String name;

  /// Catalog icon URL; empty when there is nothing to show yet.
  final String iconUrl;

  const ItemSearchResult({
    required this.id,
    required this.name,
    this.iconUrl = '',
  });
}

/// Looks up item name suggestions as the user types in "Add Item".
abstract interface class ItemSearchRepository {
  Future<Either<Failure, ({List<ItemSearchResult> items, bool hasMore})>>
  searchItems(String query, {int page = 1});
}
