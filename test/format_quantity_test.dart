import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';

void main() {
  group('formatQuantity (display)', () {
    test('drops the empty fraction', () {
      expect(formatQuantity(4.0), '4');
      expect(formatQuantity(1), '1');
    });

    test('groups thousands', () {
      expect(formatQuantity(1816.0), '1,816');
    });

    test('keeps a real fraction', () {
      expect(formatQuantity(1.5), '1.5');
      expect(formatQuantity(0.25), '0.25');
    });

    test('null is empty', () {
      expect(formatQuantity(null), '');
    });
  });

  group('formatQuantity (grouped: false, text fields)', () {
    test('stays parseable by double.tryParse', () {
      for (final value in [4.0, 1816.0, 1.5, 0.25]) {
        final text = formatQuantity(value, grouped: false);
        expect(double.tryParse(text), value, reason: text);
      }
    });

    test('drops the empty fraction', () {
      expect(formatQuantity(4.0, grouped: false), '4');
      expect(formatQuantity(1816.0, grouped: false), '1816');
    });
  });
}
