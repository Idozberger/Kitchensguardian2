import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';
import 'package:foodkitchen/core/screens/data/models/currency_model.dart';
import 'package:foodkitchen/core/utils/dev_logging.dart';
import 'package:foodkitchen/core/utils/json_conversion.dart';

abstract class ICountryCurrencyDataSource {
  Future<List<Country>> getCountries();
}

class CountryCurrencyDataSource implements ICountryCurrencyDataSource {
  static const String _jsonPath = 'assets/json/country_currency.json';

  @override
  Future<List<Country>> getCountries() async {
    try {
      devPrint('Loading countries from local JSON');
      return await _getCountriesFromAssets();
    } catch (e) {
      devPrint('Asset Error: $e');
      return [];
    }
  }

  Future<List<Country>> _getCountriesFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString(_jsonPath);
      final Object? decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        devPrint('country_currency.json root is not a list');
        return [];
      }
      final List<dynamic> data = decoded;

      devPrint('Loaded ${data.length} countries from assets');

      final countries = <Country>[];

      for (var item in data) {
        try {
          final code = item['cca2'] as String?;

          final nameObj = item['name'];
          final name = (nameObj is Map && nameObj['common'] != null)
              ? nameObj['common'] as String
              : 'Unknown';

          final currenciesObj = item['currencies'] as Map<String, dynamic>?;

          final currencies = <Currency>[];
          if (currenciesObj != null) {
            currenciesObj.forEach((String key, Object? value) {
              final Map<String, dynamic> v = jsonObjectFromResponseData(value);
              currencies.add(
                Currency(
                  code: key,
                  name: readJsonString(v, 'name'),
                  symbol: readJsonString(v, 'symbol'),
                ),
              );
            });
          }

          if (code != null) {
            countries.add(
              Country(code: code, name: name, currencies: currencies),
            );
          } else {
            devPrint('Skipping country with null code');
          }
        } catch (e) {
          devPrint('Error processing country item\n$e');
        }
      }

      countries.sort((a, b) => a.name.compareTo(b.name));
      devPrint('Processed ${countries.length} countries');

      return countries;
    } catch (e) {
      devPrint('Exception in _getCountriesFromAssets: $e');
      rethrow;
    }
  }
}
