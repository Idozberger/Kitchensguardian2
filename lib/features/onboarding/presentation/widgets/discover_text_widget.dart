import 'package:flutter/material.dart';

import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

// False positive: StatelessWidget is immutable.
// ignore: must_be_immutable
class DiscoverText extends StatelessWidget {
  const DiscoverText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'Discover ', style: textStyle(context)),
          TextSpan(
            text: 'Delicious Recipes ',
            style: textStyle(context).copyWith(color: AppColors.primaryColor),
          ),
          TextSpan(text: 'From Around The World', style: textStyle(context)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  TextStyle textStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontSize: t(16),
      fontWeight: FontWeight.w600,
    );
  }
}
