import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/receipt_scanned_details_page.dart';

PantryItem _item({
  String name = 'Milk',
  String qty = '2',
  String? unit = 'l',
  String? pantry = 'Refrigerator',
  String expiry = '2026-08-01',
  String? thumbnailBase64,
  Uint8List? fileBytes,
  String? sharedIngredientId,
}) {
  return PantryItem(
    nameController: TextEditingController(text: name),
    qtyController: TextEditingController(text: qty),
    expireDate: TextEditingController(text: expiry),
    manuFacturingDate: TextEditingController(),
    unit: unit,
    pantry: pantry,
    thumbnailBase64: thumbnailBase64,
    fileBytes: fileBytes,
  )..sharedIngredientId = sharedIngredientId;
}

void main() {
  group('receiptBuildPantryFromItems', () {
    test('maps fields, trims text, and carries the kitchenId', () async {
      final pantry = await receiptBuildPantryFromItems(
        items: [_item(name: '  Milk  ', expiry: ' 2026-08-01 ')],
        kitchenId: 'kitchen-1',
      );

      expect(pantry.kitchenId, 'kitchen-1');
      final entity = pantry.items.single;
      expect(entity.name, 'Milk');
      expect(entity.quantity, 2.0);
      expect(entity.unit, 'l');
      expect(entity.group, 'Refrigerator');
      expect(entity.expireDate, '2026-08-01');
    });

    test('falls back to "Fridge" when no pantry/group was picked', () async {
      final pantry = await receiptBuildPantryFromItems(
        items: [_item(pantry: null)],
        kitchenId: 'kitchen-1',
      );
      expect(pantry.items.single.group, 'Fridge');
    });

    test(
      'falls back to an empty unit and zero quantity when unparsable',
      () async {
        final pantry = await receiptBuildPantryFromItems(
          items: [_item(unit: null, qty: 'not-a-number')],
          kitchenId: 'kitchen-1',
        );
        final entity = pantry.items.single;
        expect(entity.unit, '');
        expect(entity.quantity, 0.0);
      },
    );

    test('passes sharedIngredientId through untouched', () async {
      final pantry = await receiptBuildPantryFromItems(
        items: [_item(sharedIngredientId: 'ing-42')],
        kitchenId: 'kitchen-1',
      );
      expect(pantry.items.single.sharedIngredientId, 'ing-42');
    });

    test('re-wraps an existing thumbnailBase64 as a data URI', () async {
      final pantry = await receiptBuildPantryFromItems(
        items: [_item(thumbnailBase64: 'ZmFrZQ==')],
        kitchenId: 'kitchen-1',
      );
      expect(pantry.items.single.thumbnail, 'data:image/jpeg;base64,ZmFrZQ==');
    });

    test('base64-encodes fileBytes when no thumbnailBase64 is set', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final pantry = await receiptBuildPantryFromItems(
        items: [_item(fileBytes: bytes)],
        kitchenId: 'kitchen-1',
      );
      expect(
        pantry.items.single.thumbnail,
        'data:image/jpeg;base64,${base64Encode(bytes)}',
      );
    });

    test('thumbnail is empty when the item has no photo at all', () async {
      final pantry = await receiptBuildPantryFromItems(
        items: [_item()],
        kitchenId: 'kitchen-1',
      );
      expect(pantry.items.single.thumbnail, '');
    });

    test('preserves item order across multiple items', () async {
      final pantry = await receiptBuildPantryFromItems(
        items: [
          _item(name: 'Milk'),
          _item(name: 'Eggs'),
        ],
        kitchenId: 'kitchen-1',
      );
      expect(pantry.items.map((i) => i.name), ['Milk', 'Eggs']);
    });
  });
}
