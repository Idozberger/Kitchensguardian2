import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/receipt_scanned_details_page.dart';

/// Guards the high-volume scan-thumbnail fix: decoding must stay lazy
/// (only happen once, on first access to `displayBytes`), and the
/// save-to-pantry payload must reuse the original base64 string as-is
/// instead of decoding then re-encoding it.
PantryItem _scanItem(String base64Payload) {
  return PantryItem(
    nameController: TextEditingController(),
    qtyController: TextEditingController(),
    expireDate: TextEditingController(),
    manuFacturingDate: TextEditingController(),
    thumbnailBase64: base64Payload,
  );
}

void main() {
  final payload = base64Encode(utf8.encode('fake-image-bytes'));

  test('displayBytes decodes once and caches into fileBytes', () {
    final item = _scanItem(payload);

    expect(item.fileBytes, isNull);

    final first = item.displayBytes;
    expect(first, isNotNull);
    expect(utf8.decode(first!), 'fake-image-bytes');

    // Corrupt the source string - if displayBytes decoded again it would
    // throw/return empty bytes instead of the cached value.
    item.thumbnailBase64 = 'not-valid-base64';
    final second = item.displayBytes;
    expect(second, same(first));
  });

  test('displayBytes returns null when there is nothing to decode', () {
    final item = _scanItem('');
    expect(item.displayBytes, isNull);
  });

  test(
    'receiptPantryItemThumbnailBase64 reuses the original payload untouched',
    () async {
      final item = _scanItem(payload);

      final result = await receiptPantryItemThumbnailBase64(item);

      expect(result, 'data:image/jpeg;base64,$payload');
      // Reusing the string must not force a decode.
      expect(item.fileBytes, isNull);
    },
  );
}
