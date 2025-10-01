import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

// ignore: must_be_immutable
class DiscoverText extends StatelessWidget {
  DiscoverText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: tr('discover'), style: textStyle(context)),
          TextSpan(
            text: tr('delicious_recipes'),
            style: textStyle(context).copyWith(color: AppColors.primaryColor),
          ),
          TextSpan(text: tr('from_world'), style: textStyle(context)),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  TextStyle textStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontSize: t(19),
      fontWeight: FontWeight.w600,
    );
  }
}
