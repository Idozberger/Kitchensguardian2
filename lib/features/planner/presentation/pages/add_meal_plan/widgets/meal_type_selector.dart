import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

class MealTypeSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const MealTypeSelector({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  static final List<Map<String, String>> _meals = [
    {"title": "Breakfast", "icon": AppAssets.breakfastSvg},
    {"title": "Lunch", "icon": AppAssets.lunchSvg},
    {"title": "Dinner", "icon": AppAssets.dinnerSvg},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Meal Type", style: Theme.of(context).textTheme.headlineLarge),
        gap(height: 20),
        ...List.generate(_meals.length, (index) {
          final meal = _meals[index];
          final isSelected = selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: UpperTile(
              callback: () => onSelected(index),
              height: h(51),
              borderColor: isSelected ? const Color(0xffFFDD98) : null,
              color: isSelected ? const Color(0xffFFFBEB) : null,
              widget: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: SvgPicture.asset(
                      meal["icon"]!,
                      color: isSelected
                          ? const Color(0xffFFDD98)
                          : Colors.black,
                    ),
                  ),
                  SizedBox(width: w(15)),
                  Text(
                    meal["title"]!,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium!.copyWith(color: Colors.black),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
