import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/data/models/scanned_item_model.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/pages/kitchen_analysis_page.dart';

/// Guards the UC-06 low-confidence fallback: the backend's `user_review`
/// bucket must survive the datasource merge (tagged as `needs_review`) all
/// the way to the `PantryItem` the review screen renders.
void main() {
  Map<String, dynamic> baseJson({bool? needsReview, String? sharedId}) => {
    'area': 'Fridge',
    'confidence': 42,
    'expiry_date': '2026-08-01',
    'name': 'Milk',
    'quantity': 1,
    'recommended_storage': 'fridge',
    'temp_id': 'temp-1',
    'unit': 'liter',
    'needs_review': ?needsReview,
    if (sharedId != null) 'shared_ingredient_id': sharedId,
  };

  group('ScannedItemModel.fromJson needsReview', () {
    test('reads true', () {
      expect(
        ScannedItemModel.fromJson(baseJson(needsReview: true)).needsReview,
        isTrue,
      );
    });

    test('reads false', () {
      expect(
        ScannedItemModel.fromJson(baseJson(needsReview: false)).needsReview,
        isFalse,
      );
    });

    test('defaults to false when absent', () {
      expect(ScannedItemModel.fromJson(baseJson()).needsReview, isFalse);
    });
  });

  test('kitchenAnalysisMapScannedToPantryItem carries needsReview', () {
    final entity = ScannedItemModel.fromJson(baseJson(needsReview: true));
    final pantryItem = kitchenAnalysisMapScannedToPantryItem(entity);
    expect(pantryItem.needsReview, isTrue);
  });

  test('kitchenAnalysisMapScannedToPantryItem carries sharedIngredientId', () {
    final entity = ScannedItemModel.fromJson(baseJson(sharedId: '12'));
    final pantryItem = kitchenAnalysisMapScannedToPantryItem(entity);
    expect(pantryItem.sharedIngredientId, '12');
  });

  test('kitchenAnalysisToEditPayload includes shared_ingredient_id', () {
    final item = kitchenAnalysisMapScannedToPantryItem(
      ScannedItemModel.fromJson(baseJson(sharedId: '12')),
    );
    final payload = kitchenAnalysisToEditPayload(item);
    expect(payload['shared_ingredient_id'], 12);
    expect(payload['recommended_storage'], 'fridge');
  });
}
