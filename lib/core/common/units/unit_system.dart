import 'package:intl/intl.dart';

/// Measurement system a kitchen uses. Stored per-kitchen on the backend as
/// `unit_system` ("metric" | "imperial"). The database always holds metric
/// quantities and the backend converts for display / normalizes on write, so
/// the client never converts numbers — it only surfaces the correct unit
/// labels for the active system.
enum UnitSystem { metric, imperial }

/// Canonical unit values per system — what the client sends/stores. These
/// mirror the backend converter's vocabulary (`IMPERIAL_UNITS` /
/// `STORAGE_LABEL`), so every unit the backend may return on read is a
/// first-class dropdown option and every unit the user picks is understood on
/// write. The discrete "pieces" unit is `unit` (KG-9: backend returns `unit`
/// for imperial / `count` for metric — both shown capitalized as "Unit" via
/// [unitDisplayLabel]). The client never converts numbers.
const List<String> _metricUnits = ['grams', 'kg', 'ml', 'litre', 'unit'];
const List<String> _imperialUnits = [
  'oz',
  'lb',
  'tsp',
  'tbsp',
  'fl oz',
  'cup',
  'quart',
  'gallon',
  'unit',
];

/// Every spelling that means the discrete "pieces" unit — the backend's current
/// `unit`, plus legacy `count`/`piece` still present in old data and scans.
const Set<String> _piecesSpellings = {
  'unit',
  'units',
  'count',
  'counts',
  'piece',
  'pieces',
  'pcs',
  'pc',
};

/// Display label for a stored/returned unit string (KG-9). The discrete unit
/// (any of [_piecesSpellings]) is shown capitalized as "Unit"; every other
/// label passes through unchanged. Purely presentational — the stored/sent
/// value is untouched.
String unitDisplayLabel(String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return value;
  return _piecesSpellings.contains(value.toLowerCase()) ? 'Unit' : value;
}

/// Whether [raw] denotes the discrete "count / pieces" unit (any of
/// [_piecesSpellings]). Used to decide when an estimated weight is worth showing
/// alongside the count (KG-16) — weight/volume units already carry their mass.
bool isPiecesUnit(String? raw) {
  final value = raw?.trim().toLowerCase() ?? '';
  return _piecesSpellings.contains(value);
}

/// Display text for a stored quantity. Quantities are canonical doubles, so a
/// plain `toString()` leaks "4.0" and "1816.0"; this drops the empty fraction
/// and groups thousands ("1,816"). Pass [grouped] false for text fields, where
/// the value must stay parseable by `double.tryParse`.
String formatQuantity(num? value, {bool grouped = true}) {
  if (value == null) return '';
  if (grouped) return NumberFormat('#,##0.###').format(value);
  return value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();
}

/// KG-16: short display label for an estimated per-unit weight in grams, e.g.
/// 400 -> "~400 g", 1200 -> "~1.2 kg". Returns null when there is nothing to
/// show (null / non-positive). Presentational only; the value stays canonical grams.
String? estimatedWeightLabel(double? grams) {
  if (grams == null || grams <= 0) return null;
  if (grams >= 1000) {
    final kg = grams / 1000;
    final text = kg == kg.roundToDouble()
        ? kg.toStringAsFixed(0)
        : kg.toStringAsFixed(1);
    return '~$text kg';
  }
  return '~${grams.round()} g';
}

/// KG-16: total estimated weight for [count] discrete units weighing
/// [perUnitGrams] each, e.g. 4 × 400 -> "~1.6 kg". Null when there is nothing
/// to show (null / non-positive per-unit weight). A missing/invalid [count] is
/// treated as 1. Builds on [estimatedWeightLabel] for the g→kg formatting.
String? estimatedTotalWeightLabel(num? count, double? perUnitGrams) {
  if (perUnitGrams == null || perUnitGrams <= 0) return null;
  final n = (count == null || count <= 0) ? 1 : count;
  return estimatedWeightLabel(perUnitGrams * n);
}

/// Maps the backend `unit_system` string to [UnitSystem]. Anything other than
/// "imperial" (including null/unknown) falls back to metric — the backend
/// default — so a missing field never breaks parsing.
UnitSystem unitSystemFromApi(String? value) {
  return value?.toLowerCase().trim() == 'imperial'
      ? UnitSystem.imperial
      : UnitSystem.metric;
}

/// The backend string for a [UnitSystem].
String unitSystemToApi(UnitSystem system) {
  return system == UnitSystem.imperial ? 'imperial' : 'metric';
}

/// The two selectable measurement systems, as the API values the backend
/// accepts on `kitchen/create` and `kitchen/set_unit_system`.
const List<String> unitSystemOptions = ['metric', 'imperial'];

/// Human label for a measurement-system option ("metric" -> "Metric").
/// Presentational only — the raw API value is what gets sent.
String unitSystemDisplayLabel(String raw) =>
    unitSystemFromApi(raw) == UnitSystem.imperial ? 'Imperial' : 'Metric';

extension UnitSystemX on UnitSystem {
  /// Canonical unit labels for this system.
  List<String> get units =>
      this == UnitSystem.imperial ? _imperialUnits : _metricUnits;

  /// Default unit for a brand-new item in this system.
  String get defaultUnit => units.first;
}

/// Unit options for a dropdown in [system]. If [current] is a non-empty value
/// whose display label isn't already represented among the options (e.g. a
/// legacy "Gram"), it is prepended so the field renders and stays selectable —
/// the union-guard. Display-aware, so legacy pieces spellings ("count"/"piece")
/// collapse onto the single "Unit" option instead of duplicating it.
List<String> unitOptions(UnitSystem system, {String? current}) {
  final options = List<String>.of(system.units);
  final value = current?.trim();
  if (value != null &&
      value.isNotEmpty &&
      !options.any((o) => unitDisplayLabel(o) == unitDisplayLabel(value))) {
    return [value, ...options];
  }
  return options;
}
