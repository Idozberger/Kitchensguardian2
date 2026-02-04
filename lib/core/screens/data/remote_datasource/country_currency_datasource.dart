import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';
import 'package:foodkitchen/core/screens/data/models/currency_model.dart';

abstract class ICountryCurrencyDataSource {
  Future<List<Country>> getCountries();
}

class CountryCurrencyDataSource implements ICountryCurrencyDataSource {
  static const String _jsonPath = 'assets/json/country_currency.json';

  @override
  Future<List<Country>> getCountries() async {
    try {
      debugPrint('Loading countries from local JSON');
      return await _getCountriesFromAssets();
    } catch (e) {
      debugPrint('Asset Error: $e');
      return [];
    }
  }

  Future<List<Country>> _getCountriesFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString(_jsonPath);
      final List<dynamic> data = jsonDecode(jsonString);

      debugPrint('Loaded ${data.length} countries from assets');

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
            currenciesObj.forEach((key, value) {
              currencies.add(
                Currency(
                  code: key,
                  name: value['name'] ?? '',
                  symbol: value['symbol'] ?? '',
                ),
              );
            });
          }

          if (code != null) {
            countries.add(
              Country(code: code, name: name, currencies: currencies),
            );
          } else {
            debugPrint('Skipping country with null code');
          }
        } catch (e) {
          debugPrint('Error processing country item\n$e');
        }
      }

      countries.sort((a, b) => a.name.compareTo(b.name));
      debugPrint('Processed ${countries.length} countries');

      return countries;
    } catch (e) {
      debugPrint('Exception in _getCountriesFromAssets: $e');
      rethrow;
    }
  }
}
