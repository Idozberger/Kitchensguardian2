import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/data/models/scanned_item_model.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/pages/kitchen_analysis_page.dart';

/// Guards the UC-06 low-confidence fallback: the backend's `user_review`
/// bucket must survive the datasource merge (tagged as `needs_review`) all
/// the way to the `PantryItem` the review screen renders.
void main() {
  Map<String, dynamic> baseJson({bool? needsReview}) => {
    'area': 'Fridge',
    'confidence': 42,
    'expiry_date': '2026-08-01',
    'name': 'Milk',
    'quantity': 1,
    'recommended_storage': 'Fridge',
    'temp_id': 'temp-1',
    'unit': 'liter',
    'needs_review': ?needsReview,
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
}
