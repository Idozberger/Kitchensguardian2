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
}) {
  return PantryItem(
    nameController: TextEditingController(text: name),
    qtyController: TextEditingController(text: qty),
    expireDate: TextEditingController(text: expiry),
    manuFacturingDate: TextEditingController(),
    unit: unit,
    pantry: pantry,
  );
}

void main() {
  group('receiptValidatePantryItem', () {
    test('returns null for a fully valid item', () {
      expect(receiptValidatePantryItem(_item(), 0), isNull);
    });

    test('empty name uses "Item N" in the message', () {
      final message = receiptValidatePantryItem(_item(name: ''), 2);
      expect(message, 'Item 3: please enter the item name.');
    });

    test('name shorter than 3 characters is rejected', () {
      final message = receiptValidatePantryItem(_item(name: 'ab'), 0);
      expect(message, 'ab: item name must be at least 3 characters long.');
    });

    test('empty quantity is rejected', () {
      final message = receiptValidatePantryItem(_item(qty: ''), 0);
      expect(message, 'Milk: please enter the quantity.');
    });

    test('non-numeric quantity is rejected', () {
      final message = receiptValidatePantryItem(_item(qty: 'abc'), 0);
      expect(message, 'Milk: quantity must be a valid number greater than 0.');
    });

    test('zero or negative quantity is rejected', () {
      expect(
        receiptValidatePantryItem(_item(qty: '0'), 0),
        'Milk: quantity must be a valid number greater than 0.',
      );
      expect(
        receiptValidatePantryItem(_item(qty: '-1'), 0),
        'Milk: quantity must be a valid number greater than 0.',
      );
    });

    test('missing unit is rejected', () {
      final message = receiptValidatePantryItem(_item(unit: null), 0);
      expect(message, 'Milk: please select a unit.');
    });

    test('missing pantry is rejected', () {
      final message = receiptValidatePantryItem(_item(pantry: ''), 0);
      expect(message, 'Milk: please select a pantry.');
    });

    test('missing expiry date is rejected', () {
      final message = receiptValidatePantryItem(_item(expiry: ''), 0);
      expect(message, 'Milk: please enter the expiring date.');
    });
  });
}
