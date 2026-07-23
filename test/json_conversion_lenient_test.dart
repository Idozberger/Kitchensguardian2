import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

/// The scan API sends the *string* `"null"` where a JSON null is meant, and
/// occasionally quotes numbers. A printed map hides the difference, so these
/// guard the readers that used to be raw `as num?` casts and threw.
void main() {
  group('readJsonDoubleOrNull', () {
    test('the backend\'s "null" sentinel becomes null, not a crash', () {
      expect(readJsonDoubleOrNull({'g': 'null'}, 'g'), isNull);
    });

    test('real null and a missing key are null', () {
      expect(readJsonDoubleOrNull({'g': null}, 'g'), isNull);
      expect(readJsonDoubleOrNull({}, 'g'), isNull);
    });

    test('numbers pass through, quoted or not', () {
      expect(readJsonDoubleOrNull({'g': 454}, 'g'), 454.0);
      expect(readJsonDoubleOrNull({'g': 454.0}, 'g'), 454.0);
      expect(readJsonDoubleOrNull({'g': '454'}, 'g'), 454.0);
    });
  });

  group('readJsonStringOrNull', () {
    test('"null" and empty collapse to null', () {
      expect(readJsonStringOrNull({'b': 'null'}, 'b'), isNull);
      expect(readJsonStringOrNull({'b': '  '}, 'b'), isNull);
      expect(readJsonStringOrNull({}, 'b'), isNull);
    });

    test('a real value survives', () {
      expect(readJsonStringOrNull({'b': 'per_unit'}, 'b'), 'per_unit');
    });
  });

  group('readJsonDouble / readJsonInt tolerate quoted numbers', () {
    test('quoted number parses instead of falling back', () {
      expect(readJsonDouble({'q': '778.0'}, 'q'), 778.0);
      expect(readJsonInt({'q': '778'}, 'q'), 778);
    });

    test('unparseable falls back rather than throwing', () {
      expect(readJsonDouble({'q': 'high'}, 'q'), 0);
      expect(readJsonInt({'q': 'high'}, 'q'), 0);
    });
  });
}
