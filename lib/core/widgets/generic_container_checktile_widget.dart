import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class GenericCircleCheckboxTile extends StatelessWidget {
  final String title;
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final Color activeColor;
  final Color checkColor;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry contentPadding;

  const GenericCircleCheckboxTile({
    super.key,
    required this.title,
    required this.isChecked,
    required this.onChanged,
    required this.activeColor,
    this.checkColor = Colors.white,
    this.textStyle,

    this.contentPadding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: contentPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => onChanged(!isChecked),
            child: Container(
              padding: gapAll(1),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryColor, width: 2),
                color: isChecked ? activeColor : Colors.transparent,
              ),
              child: Icon(Icons.check, size: t(12), color: checkColor),
            ),
          ),
          SizedBox(width: w(14)),

          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(!isChecked),
              child: Text(
                title,
                style: textStyle ?? Theme.of(context).textTheme.headlineMedium!,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
