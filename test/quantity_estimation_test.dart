import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';

/// Guards the KG-16 "weight alongside count" display helpers.
///
/// The backend returns `estimated_weight_grams` only for discrete/count goods
/// (e.g. "1 can ~400g"); it is null for countable produce and for weight/volume
/// units, whose mass already lives in the quantity itself.
///
/// The scan-review UI shows the hint only when BOTH [estimatedWeightLabel]
/// yields a label AND [isPiecesUnit] is true for the item's unit. So the two
/// must stay in sync with the same pieces vocabulary that [unitDisplayLabel]
/// collapses to "Unit" — a unit added to one and not the other would silently
/// hide (or wrongly show) the weight.
void main() {
  group('isPiecesUnit', () {
    test('recognizes every discrete spelling backend/legacy data can send', () {
      for (final raw in [
        'unit',
        'units',
        'count',
        'counts',
        'piece',
        'pieces',
        'pcs',
        'pc',
      ]) {
        expect(isPiecesUnit(raw), isTrue, reason: '"$raw" should be discrete');
      }
    });

    test('is case- and whitespace-insensitive', () {
      expect(isPiecesUnit('Unit'), isTrue);
      expect(isPiecesUnit('COUNT'), isTrue);
      expect(isPiecesUnit('  count  '), isTrue);
    });

    test(
      'rejects weight/volume units — their mass is already the quantity',
      () {
        for (final raw in ['grams', 'kg', 'ml', 'litre', 'oz', 'lb', 'cup']) {
          expect(isPiecesUnit(raw), isFalse, reason: '"$raw" is not discrete');
        }
      },
    );

    test('treats null/empty as not discrete', () {
      expect(isPiecesUnit(null), isFalse);
      expect(isPiecesUnit(''), isFalse);
      expect(isPiecesUnit('   '), isFalse);
    });

    test('agrees with unitDisplayLabel on the pieces vocabulary', () {
      for (final raw in ['unit', 'count', 'piece', 'pcs']) {
        expect(unitDisplayLabel(raw), 'Unit');
        expect(isPiecesUnit(raw), isTrue);
      }
    });
  });

  group('estimatedWeightLabel', () {
    test('renders grams below 1kg, rounded to a whole number', () {
      expect(estimatedWeightLabel(400), '~400 g'); // standard can
      expect(estimatedWeightLabel(150), '~150 g'); // tuna can
      expect(estimatedWeightLabel(50), '~50 g'); // one egg
      expect(estimatedWeightLabel(999), '~999 g');
      expect(estimatedWeightLabel(49.6), '~50 g');
    });

    test('switches to kg at 1000g and drops a trailing .0', () {
      expect(estimatedWeightLabel(1000), '~1 kg');
      expect(estimatedWeightLabel(2000), '~2 kg');
    });

    test('keeps one decimal for fractional kilograms', () {
      expect(estimatedWeightLabel(1200), '~1.2 kg');
      expect(estimatedWeightLabel(1500), '~1.5 kg');
    });

    test('returns null when there is nothing to show', () {
      // Produce and weight/volume units come back with a null weight.
      expect(estimatedWeightLabel(null), isNull);
      expect(estimatedWeightLabel(0), isNull);
      expect(estimatedWeightLabel(-5), isNull);
    });
  });

  group('estimatedTotalWeightLabel', () {
    test('multiplies the per-unit weight by the count', () {
      expect(estimatedTotalWeightLabel(4, 400), '~1.6 kg'); // 4 cans
      expect(estimatedTotalWeightLabel(1, 400), '~400 g'); // one can
      expect(estimatedTotalWeightLabel(3, 150), '~450 g');
    });

    test('treats a missing/invalid count as 1', () {
      expect(estimatedTotalWeightLabel(null, 400), '~400 g');
      expect(estimatedTotalWeightLabel(0, 400), '~400 g');
      expect(estimatedTotalWeightLabel(-2, 400), '~400 g');
    });

    test('returns null when there is no per-unit weight to show', () {
      expect(estimatedTotalWeightLabel(3, null), isNull);
      expect(estimatedTotalWeightLabel(3, 0), isNull);
    });
  });
}
