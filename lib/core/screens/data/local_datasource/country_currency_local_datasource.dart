import 'package:flutter/material.dart';
import 'package:foodkitchen/core/screens/data/local_datasource/country_currency_cache.dart';
import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';
import 'package:foodkitchen/core/screens/data/remote_datasource/country_currency_datasource.dart';

class CachedCountryCurrencyRepository {
  final ICountryCurrencyDataSource _dataSource;
  final CountryCurrencyCache _cache;

  CachedCountryCurrencyRepository({
    required ICountryCurrencyDataSource dataSource,
    required CountryCurrencyCache cache,
  }) : _dataSource = dataSource,
       _cache = cache;
  Future<List<Country>> getCountries({
    bool forceRefresh = false,
    bool useOfflineFirst = true,
  }) async {
    try {
      final cached = _cache.getCountries();
      if (cached.isNotEmpty) return cached;

      final countries = await _dataSource.getCountries();

      await _cache.saveCountries(countries);

      return countries;
    } catch (e) {
      debugPrint('Error fetching countries: $e');
      return _cache.getCountries();
    }
  }
}
