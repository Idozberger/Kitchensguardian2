import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/screens/data/models/country_currency_model.dart';
import 'package:foodkitchen/core/screens/data/models/currency_model.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

class SummaryCard extends StatelessWidget {
  final Country selectedCountry;
  final Currency selectedCurrency;

  const SummaryCard({
    super.key,
    required this.selectedCountry,
    required this.selectedCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: gapSymmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE5E7EB), width: w(1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: w(134)),
            child: Text(
              selectedCountry.name,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontSize: t(12),
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          gap(width: 14),
          Container(width: w(1), height: h(20), color: Colors.grey[300]),
          gap(width: 14),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: w(144)),
            child: Text(
              '${selectedCurrency.symbol} ${selectedCurrency.code}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                fontSize: t(12),
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
