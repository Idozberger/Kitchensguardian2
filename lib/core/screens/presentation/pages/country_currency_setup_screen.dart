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

  const CountryAndCurrencySetupScreen({super.key, this.isUpdating = false});

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
  List<Currency> _availableCurrencies = [];
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

      if (_countries.isNotEmpty) {
        if (widget.isUpdating) {
          String? savedCountryCode = pref.getString('country');
          String? savedCurrencyCode = pref.getString('currency');

          if (savedCountryCode != null) {
            _selectedCountry = _countries.firstWhere(
              (c) => c.code == savedCountryCode,
              orElse: () => _countries.first,
            );
          } else {
            _selectedCountry = _countries.firstWhere(
              (c) => c.code == 'US',
              orElse: () => _countries.first,
            );
          }

          _availableCurrencies = _selectedCountry!.currencies;

          if (savedCurrencyCode != null) {
            _selectedCurrency = _availableCurrencies.firstWhere(
              (c) => c.code == savedCurrencyCode,
            );
          } else {
            _selectedCurrency = _availableCurrencies.isNotEmpty
                ? _availableCurrencies.first
                : null;
          }
        } else {
          _selectedCountry = _countries.firstWhere(
            (c) => c.code == 'US',
            orElse: () => _countries.first,
          );
          _availableCurrencies = _selectedCountry!.currencies;
          if (_availableCurrencies.isNotEmpty) {
            _selectedCurrency = _availableCurrencies.first;
          }
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
      _availableCurrencies = country.currencies;
      _selectedCurrency = _availableCurrencies.isNotEmpty
          ? _availableCurrencies.first
          : null;
    });
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
          context.go(Routes.kitchenSelection);
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
                  currencies: _availableCurrencies,
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
