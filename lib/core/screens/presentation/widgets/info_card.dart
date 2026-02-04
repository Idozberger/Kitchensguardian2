import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_snippet.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: gapAll(14),
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(t(16)),
        border: Border.all(color: Color(0xFFE5E7EB), width: w(1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryColor,
                size: t(18),
              ),
              SizedBox(width: w(12)),
              Text(
                'Why is this important?',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: t(14),
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          gapH(12),
          Text(
            'We need this information to provide accurate receipt scanning and pricing conversion. Your country and currency settings ensure that your expense data is properly formatted and calculated.',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: t(13),
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
