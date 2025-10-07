import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

class PlanOptionTile extends StatelessWidget {
  final String title;
  final String price;
  final String? badgeText;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;

  const PlanOptionTile({
    super.key,
    required this.title,
    required this.price,
    this.badgeText,
    this.isSelected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => onSelected?.call(true),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: h(16), horizontal: w(0)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(h(12)),
              border: Border.all(
                color: isSelected
                    ? AppColors.primaryColor
                    : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Radio(
                  value: true,
                  groupValue: isSelected,
                  fillColor: WidgetStatePropertyAll(AppColors.primaryColor),
                  onChanged: (_) => onSelected?.call(true),
                ),
                SizedBox(width: w(15)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineLarge!
                          .copyWith(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                    ),
                    gap(height: 6),
                    Text(
                      price,
                      style: Theme.of(context).textTheme.headlineLarge!
                          .copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (badgeText != null && isSelected)
          Positioned(
            top: h(-10),
            left: 0,
            right: 0,
            child: Center(
              child: IntrinsicWidth(
                child: Container(
                  padding: gapSymmetric(vertical: 3, horizontal: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(h(40)),
                    color: AppColors.primaryColor,
                  ),
                  child: Text(
                    badgeText!,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Colors.black,
                      fontSize: t(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
