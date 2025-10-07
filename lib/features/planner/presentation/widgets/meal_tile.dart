import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';

class MealTile extends StatelessWidget {
  final String mealType;
  final String mealName;

  const MealTile({super.key, required this.mealType, required this.mealName});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(AppAssets.addSvg),
      dense: true,
      contentPadding: gapZero,
      title: Row(
        children: [
          Text(
            "$mealType: ",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.black),
          ),
          Flexible(
            child: Text(
              mealName,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xff787878),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
