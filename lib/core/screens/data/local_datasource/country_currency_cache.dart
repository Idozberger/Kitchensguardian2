import 'dart:convert';

import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountryCurrencyCache {
  static const String countriesKey = 'cached_countries_v1';
  static const String currenciesKey = 'cached_currencies';

  final SharedPreferences _prefs;

  CountryCurrencyCache(this._prefs);

  List<Country> getCountries() {
    final cached = _prefs.getString(countriesKey);
    if (cached == null) return [];

    try {
      final Object? decoded = jsonDecode(cached);
      if (decoded is! List) return [];
      return decoded
          .map((Object? e) => Country.fromMap(jsonObjectFromResponseData(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveCountries(List<Country> countries) async {
    final jsonString = jsonEncode(countries.map((e) => e.toMap()).toList());
    await _prefs.setString(countriesKey, jsonString);
  }
}
