import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/country_item.dart';

class CountryDropdown extends StatelessWidget {
  final List<Country> countries;
  final Country? selectedCountry;
  final void Function(Country?) onChanged;

  const CountryDropdown({
    super.key,
    required this.countries,
    required this.selectedCountry,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(t(12)),
        child: Container(
          padding: gapSymmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(t(12)),
            border: Border.all(color: Color(0xFFE5E7EB), width: 1.5),
          ),
          child: DropdownButton<Country>(
            isExpanded: true,
            underline: SizedBox(),
            value: selectedCountry,
            onChanged: onChanged,
            dropdownColor: Colors.white,
            style: TextStyle(
              fontSize: t(16),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF2563eb),
              size: t(24),
            ),
            items: countries
                .map(
                  (country) => DropdownMenuItem(
                    value: country,
                    child: CountryItem(country: country),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
