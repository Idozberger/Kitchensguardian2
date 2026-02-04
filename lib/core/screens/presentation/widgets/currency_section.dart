import 'package:flutter/material.dart';
import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';
import 'package:foodkitchen/core/screens/data/models/currency_model.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/currency_dropdown.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/section_title.dart';

class CurrencySection extends StatelessWidget {
  final List<Currency> currencies;
  final Currency? selectedCurrency;
  final Country? selectedCountry;
  final Function(Currency?) onCurrencyChanged;

  const CurrencySection({
    super.key,
    required this.currencies,
    required this.selectedCurrency,
    required this.selectedCountry,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('Select Your Currency'),
        SizedBox(height: 12),
        CurrencyDropdown(
          currencies: currencies,
          selectedCurrency: selectedCurrency,
          selectedCountry: selectedCountry,
          onChanged: onCurrencyChanged,
        ),
      ],
    );
  }
}
