import 'package:foodkitchen/core/error/failures.dart';
import 'package:foodkitchen/features/pantry/domain/repository/item_search_repository.dart';
import 'package:fpdart/fpdart.dart';

// ponytail: hardcoded catalog stands in for a real search endpoint;
// swap the body of searchItems for an API call once the backend exists.
const _mockItemCatalog = <String>[
  'Milk',
  'Milk1',
  'Milk2',
  'Milk3',
  'Milk4',
  'Milk5',
  'Milk',
  'Milk',
  'Eggs',
  'Butter',
  'Cheddar Cheese',
  'Yogurt',
  'Bread',
  'Bananas',
  'Apples',
  'Oranges',
  'Tomatoes',
  'Potatoes',
  'Onions',
  'Garlic',
  'Carrots',
  'Broccoli',
  'Spinach',
  'Chicken Breast',
  'Ground Beef',
  'Salmon Fillet',
  'Shrimp',
  'Bacon',
  'Rice',
  'Pasta',
  'Olive Oil',
  'Flour',
  'Sugar',
  'Salt',
  'Black Pepper',
  'Coffee',
  'Tea',
  'Orange Juice',
  'Almond Milk',
  'Peanut Butter',
  'Honey',
  'Ketchup',
  'Mayonnaise',
  'Mustard',
  'Cereal',
  'Oats',
];

class ItemSearchRepositoryImpl implements ItemSearchRepository {
  @override
  Future<Either<Failure, List<String>>> searchItems(String query) async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final trimmed = query.trim().toLowerCase();
      final results = trimmed.isEmpty
          ? _mockItemCatalog
          : _mockItemCatalog
                .where((item) => item.toLowerCase().contains(trimmed))
                .toList();
      return Right(results);
    } catch (e) {
      return Left(unknownFailureFrom(e));
    }
  }
}
