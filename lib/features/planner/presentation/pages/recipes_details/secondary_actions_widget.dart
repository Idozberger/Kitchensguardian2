import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class SecondaryActionsWidget extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabSelected;

  const SecondaryActionsWidget({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildSecondaryActionButton(context, "Ingredients", 0)),
        Expanded(child: _buildSecondaryActionButton(context, "Recipe", 1)),
      ],
    );
  }

  Widget _buildSecondaryActionButton(
    BuildContext context,
    String label,
    int index,
  ) {
    final bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabSelected(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: h(8)),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected
                  ? AppColors.primaryColor
                  : const Color(0xffD4D2D2),
              width: 3,
            ),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: t(14),
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xff787878),
          ),
        ),
      ),
    );
  }
}
