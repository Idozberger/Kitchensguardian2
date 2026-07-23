import 'package:flutter_test/flutter_test.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';

/// Guards the union-guard in [unitOptions] (KG-9): a dropdown must always be
/// able to render and keep the item's current unit selectable, even a legacy
/// value the current system no longer lists — without duplicating the single
/// display-collapsed "Unit" option.
void main() {
  group('unitOptions', () {
    test('returns the canonical set for each system when no current value', () {
      expect(unitOptions(UnitSystem.metric), UnitSystem.metric.units);
      expect(unitOptions(UnitSystem.imperial), UnitSystem.imperial.units);
    });

    test(
      'null / empty / whitespace current leaves the base list untouched',
      () {
        final base = UnitSystem.metric.units;
        expect(unitOptions(UnitSystem.metric, current: null), base);
        expect(unitOptions(UnitSystem.metric, current: ''), base);
        expect(unitOptions(UnitSystem.metric, current: '   '), base);
      },
    );

    test('a current value already in the set is not prepended', () {
      final result = unitOptions(UnitSystem.metric, current: 'kg');
      expect(result, UnitSystem.metric.units);
      expect(result.where((o) => o == 'kg').length, 1);
    });

    test(
      'a foreign/legacy current value is prepended so it stays selectable',
      () {
        // "Gram" (legacy capitalization) is not among the metric canon.
        final result = unitOptions(UnitSystem.metric, current: 'Gram');
        expect(result.first, 'Gram');
        expect(result.sublist(1), UnitSystem.metric.units);
      },
    );

    test('an imperial unit shown under metric is prepended', () {
      final result = unitOptions(UnitSystem.metric, current: 'oz');
      expect(result.first, 'oz');
      expect(result.length, UnitSystem.metric.units.length + 1);
    });

    test('legacy pieces spellings collapse onto the single "Unit" option', () {
      // "count" / "piece" display as "Unit", which the metric set already
      // carries as "unit" — so nothing is prepended and no duplicate appears.
      for (final legacy in ['count', 'piece', 'pieces', 'PCS']) {
        final result = unitOptions(UnitSystem.metric, current: legacy);
        expect(
          result,
          UnitSystem.metric.units,
          reason: '"$legacy" should not add a second pieces option',
        );
        expect(result.where((o) => unitDisplayLabel(o) == 'Unit').length, 1);
      }
    });
  });
}
