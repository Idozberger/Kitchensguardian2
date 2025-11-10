import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/widgets/rounded_text_container.dart';

class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: h(40),
      width: double.infinity,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        shrinkWrap: true,
        padding: gapSymmetric(horizontal: 20),
        separatorBuilder: (_, __) => gap(width: 8),
        itemBuilder: (_, index) {
          return InkWell(
            borderRadius: BorderRadius.circular(h(50)),
            onTap: () => onTabSelected(index),
            child: RoundedTextContainer(
              isBordered: true,
              borderColor: selectedIndex == index
                  ? AppColors.primaryColor
                  : const Color(0xffD4D2D2),
              horizontalPad: 14,
              verticalPad: 0,
              text: categories[index],
              backgroundColor: selectedIndex == index
                  ? AppColors.primaryColor
                  : Colors.white,
              textColor: Colors.black,
            ),
          );
        },
      ),
    );
  }
}
