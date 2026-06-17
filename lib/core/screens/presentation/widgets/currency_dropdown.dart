import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';
import 'package:foodkitchen/core/screens/data/models/currency_model.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/currency_item.dart';

class CurrencyDropdown extends StatelessWidget {
  final List<Currency> currencies;
  final Currency? selectedCurrency;
  final Country? selectedCountry;
  final void Function(Currency?) onChanged;

  const CurrencyDropdown({
    super.key,
    required this.currencies,
    required this.selectedCurrency,
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
            blurRadius: t(12),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(t(12)),
        child: Container(
          padding: gapSymmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(t(12)),
            border: Border.all(color: Color(0xFFE5E7EB), width: 1.5),
          ),
          child: DropdownButton<Currency>(
            isExpanded: true,
            underline: SizedBox(),
            value: selectedCurrency,
            onChanged: onChanged,
            dropdownColor: Colors.white,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: t(16),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            icon: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
              size: t(24),
            ),
            items: currencies
                .map(
                  (currency) => DropdownMenuItem(
                    value: currency,
                    child: CurrencyItem(
                      currency: currency,
                      isDefault:
                          currency.code ==
                          selectedCountry?.currencies.first.code,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
