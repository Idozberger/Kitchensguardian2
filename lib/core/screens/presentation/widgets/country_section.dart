import 'package:flutter/material.dart';
import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/country_dropdown_with_search.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/section_title.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_snippet.dart';

class CountrySection extends StatelessWidget {
  final List<Country> countries;
  final Country? selectedCountry;
  final void Function(Country?) onCountryChanged;

  const CountrySection({
    super.key,
    required this.countries,
    required this.selectedCountry,
    required this.onCountryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle('Select Your Country'),
        gapH(12),
        CountryDropdownWithSearch(
          countries: countries,
          selectedCountry: selectedCountry,
          onChanged: onCountryChanged,
        ),
      ],
    );
  }
}
