import 'package:flutter/material.dart';
import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';
import 'package:foodkitchen/core/screens/data/models/currency_model.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/continue_button.dart';
import 'package:foodkitchen/core/screens/presentation/widgets/summary_card.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_snippet.dart';

class ActionButtons extends StatelessWidget {
  final bool isLoading;
  final Country? selectedCountry;
  final bool isUpdating;
  final Currency? selectedCurrency;
  final VoidCallback onContinue;

  const ActionButtons({
    super.key,
    required this.isLoading,
    required this.selectedCountry,
    required this.selectedCurrency,
    required this.isUpdating,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ContinueButton(
          isLoading: isLoading,
          onPressed: onContinue,
          isUpdating: isUpdating,
        ),
        gapH(14),
        if (selectedCountry != null && selectedCurrency != null)
          SummaryCard(
            selectedCountry: selectedCountry!,
            selectedCurrency: selectedCurrency!,
          ),
      ],
    );
  }
}
