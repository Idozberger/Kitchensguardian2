import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class ListItemWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final CrossAxisAlignment crossAlignment;
  const ListItemWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.crossAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: crossAlignment,
      children: [
        Padding(
          padding: crossAlignment == CrossAxisAlignment.center
              ? gapZero
              : gapOnly(top: 4),
          child: Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        SizedBox(width: w(7)),
        Flexible(
          child: Text(
            text,

            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: t(15),
              fontWeight: FontWeight.w400,
              color: Color(0xff787878),
            ),
          ),
        ),
      ],
    );
  }
}
