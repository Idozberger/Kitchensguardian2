import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

// ignore: must_be_immutable
class DiscoverText extends StatelessWidget {
  DiscoverText({super.key});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: tr('discover'), style: textStyle),
          TextSpan(
            text: tr('delicious_recipes'),
            style: textStyle.copyWith(color: AppColors.primaryColor),
          ),
          TextSpan(text: tr('from_world'), style: textStyle),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  TextStyle textStyle = TextStyle(
    fontSize: 20,
    color: Colors.black,
    fontWeight: FontWeight.w600,
  );
}
