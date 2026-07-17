import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/common/data/model/pantry_model.dart';
import 'package:foodkitchen/core/common/data/model/requested_items_model.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/widgets/safe_image.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/my_pantry/my_pantry_filter_sheet.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/pantry_item_card.dart';

/// Groundwork for BRD Icon Caching (UC-08/UC-09): the client doesn't call any
/// AI icon endpoint yet, it only needs to carry and render a future
/// `icon_url` field without breaking today's photo-thumbnail behavior.
void main() {
  group('icon_url model round-trip', () {
    test('PantryItemModel reads and writes icon_url', () {
      final withIcon = PantryItemModel.fromJson({
        'name': 'Milk',
        'item_id': 'item-1',
        'icon_url': 'https://cdn.example.com/icons/milk.png',
      });
      expect(withIcon.iconUrl, 'https://cdn.example.com/icons/milk.png');
      expect(withIcon.toJson()['icon_url'], withIcon.iconUrl);

      final withoutIcon = PantryItemModel.fromJson({
        'name': 'Eggs',
        'item_id': 'item-2',
      });
      expect(withoutIcon.iconUrl, '');
    });

    test('RequestedItemModel reads and writes icon_url', () {
      final withIcon = RequestedItemModel.fromJson({
        '_id': 'req-1',
        'icon_url': 'https://cdn.example.com/icons/bread.png',
      });
      expect(withIcon.iconUrl, 'https://cdn.example.com/icons/bread.png');
      expect(withIcon.toJson()['icon_url'], withIcon.iconUrl);

      final withoutIcon = RequestedItemModel.fromJson({'_id': 'req-2'});
      expect(withoutIcon.iconUrl, '');
    });
  });

  testWidgets(
    'pantry card falls back from the photo to the AI icon to the generic icon',
    (tester) async {
      final entity = PantryItemEntity(
        name: 'Milk',
        quantity: 1,
        unit: 'unit',
        group: 'dairy',
        expireDate: '',
        thumbnail: '',
        expiryStatus: '',
        stockStatus: '',
        itemId: 'item-1',
        iconUrl: 'https://cdn.example.com/icons/milk.png',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PantryItemCard(
              title: entity.name,
              quantity: '1',
              thumbnail: Uint8List(0),
              unit: entity.unit,
              pantry: 'Fridge',
              expiry: '',
              onListCheckedCallback: () {},
              onCartItem: () {},
              selectedFilter: PantryFilter.all,
              pantryItemEntity: entity,
              kitchenId: 'kitchen-1',
              isLocked: false,
            ),
          ),
        ),
      );

      // No user photo (empty bytes) -> SafeMemoryImage must fall back to the
      // AI icon instead of jumping straight to the generic placeholder.
      final memoryImage = tester.widget<SafeMemoryImage>(
        find.byType(SafeMemoryImage),
      );
      expect(memoryImage.fallback, isA<SafeNetworkImage>());

      final networkImage = memoryImage.fallback as SafeNetworkImage;
      expect(networkImage.url, entity.iconUrl);
      // ...and the AI icon itself still falls back to the generic icon if
      // its URL ever fails to load.
      expect(networkImage.fallback, isA<Container>());
    },
  );
}
