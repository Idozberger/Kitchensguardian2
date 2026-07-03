import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/screens/data/local_datasource/country_currency_cache.dart';
import 'package:foodkitchen/core/screens/data/local_datasource/country_currency_local_datasource.dart';
import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';
import 'package:foodkitchen/core/screens/data/models/currency_model.dart';
import 'package:foodkitchen/core/screens/data/remote_datasource/country_currency_datasource.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/action_buttons.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/country_section.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/currency_section.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/info_card.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/loading_state.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/screen_header.dart';
import 'package:foodkitchen/core/services/di/service_locator.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_snippet.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountryAndCurrencySetupScreen extends StatefulWidget {
  final bool isUpdating;

  /// Where to go after a first-time save (ignored when [isUpdating]).
  final String nextRoute;

  const CountryAndCurrencySetupScreen({
    super.key,
    this.isUpdating = false,
    this.nextRoute = Routes.kitchenSelection,
  });

  @override
  State<CountryAndCurrencySetupScreen> createState() =>
      _CountryAndCurrencySetupScreenState();
}

class _CountryAndCurrencySetupScreenState
    extends State<CountryAndCurrencySetupScreen> {
  late Country? _selectedCountry;
  late Currency? _selectedCurrency;
  bool _isLoading = false;
  List<Country> _countries = [];
  List<Currency> _allCurrencies = [];
  bool _isLoadingData = true;
  late CachedCountryCurrencyRepository _localDataSource;

  @override
  void initState() {
    super.initState();
    _selectedCountry = null;
    _selectedCurrency = null;
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      SharedPreferences pref = sl<SharedPreferences>();
      _localDataSource = CachedCountryCurrencyRepository(
        dataSource: CountryCurrencyDataSource(),
        cache: CountryCurrencyCache(pref),
      );
      _countries = await _localDataSource.getCountries();
      _allCurrencies = _buildAllCurrencies(_countries);

      if (_countries.isNotEmpty) {
        if (widget.isUpdating) {
          final String? savedCountryCode = pref.getString('country');
          final String? savedCurrencyCode = pref.getString('currency');

          _selectedCountry = _countries.firstWhere(
            (c) => c.code == (savedCountryCode ?? 'US'),
            orElse: () => _countries.first,
          );
          _selectedCurrency =
              _currencyByCode(savedCurrencyCode) ??
              _defaultCurrencyFor(_selectedCountry!);
        } else {
          _selectedCountry = _countries.firstWhere(
            (c) => c.code == 'US',
            orElse: () => _countries.first,
          );
          _selectedCurrency = _defaultCurrencyFor(_selectedCountry!);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error loading countries and currencies: $e');
    } finally {
      if (mounted) _isLoadingData = false;
      setState(() {});
    }
  }

  void _onCountryChanged(Country? country) {
    if (country == null) return;
    setState(() {
      _selectedCountry = country;
      // Default to the country's primary currency, but the full list stays
      // available so the user can pick any currency (e.g. UAH while in PL).
      _selectedCurrency = _defaultCurrencyFor(country);
    });
  }

  /// Flatten every country's currencies into a single list, deduped by [code].
  /// Instances are reused so [DropdownButton] identity matching stays valid.
  List<Currency> _buildAllCurrencies(List<Country> countries) {
    final seen = <String>{};
    final result = <Currency>[
      for (final country in countries)
        for (final currency in country.currencies)
          if (seen.add(currency.code)) currency,
    ];
    result.sort((a, b) => a.code.compareTo(b.code));
    return result;
  }

  /// Resolve a currency [code] to the shared instance in [_allCurrencies].
  Currency? _currencyByCode(String? code) {
    if (code == null) return null;
    for (final currency in _allCurrencies) {
      if (currency.code == code) return currency;
    }
    return null;
  }

  /// The shared-list instance of a country's primary currency, or the first
  /// available currency as a fallback.
  Currency? _defaultCurrencyFor(Country country) {
    if (country.currencies.isNotEmpty) {
      final match = _currencyByCode(country.currencies.first.code);
      if (match != null) return match;
    }
    return _allCurrencies.isNotEmpty ? _allCurrencies.first : null;
  }

  Future<void> _savePreferences() async {
    if (_selectedCountry == null || _selectedCurrency == null) {
      _showErrorSnackBar('Please select both country and currency');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final prefs = sl<SharedPreferences>();
      await Future.wait([
        prefs.setString('country', _selectedCountry!.code),
        prefs.setString('currency', _selectedCurrency!.code),
        prefs.setString('country_name', _selectedCountry!.name),
        prefs.setString('currency_symbol', _selectedCurrency!.symbol),
        prefs.setString('currency_name', _selectedCurrency!.name),
      ]);

      if (mounted) {
        if (widget.isUpdating) {
          context.pop();
        } else {
          context.go(widget.nextRoute);
        }
      }
    } catch (e) {
      _showErrorSnackBar('Error saving preferences: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) return const LoadingScreen();
    return Scaffold(
      appBar: widget.isUpdating ? AppBar() : null,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: gapSymmetric(
              horizontal: 20,
              vertical: widget.isUpdating ? 8 : 28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ScreenHeader(),
                gapH(18),
                const InfoCard(),
                gapH(24),
                CountrySection(
                  countries: _countries,
                  selectedCountry: _selectedCountry,
                  onCountryChanged: _onCountryChanged,
                ),
                gapH(18),
                CurrencySection(
                  currencies: _allCurrencies,
                  selectedCurrency: _selectedCurrency,
                  selectedCountry: _selectedCountry,
                  onCurrencyChanged: (currency) {
                    setState(() => _selectedCurrency = currency);
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: gapSymmetric(
            horizontal: 20,
            vertical: Platform.isAndroid ? 8 : 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              gapH(24),
              ActionButtons(
                isLoading: _isLoading,
                selectedCountry: _selectedCountry,
                selectedCurrency: _selectedCurrency,
                onContinue: _savePreferences,
                isUpdating: widget.isUpdating,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
