import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

class RecipeCard extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback onTap;
  final bool isTodayPlan;
  final String? mealType;
  const RecipeCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.width = 258,
    this.height = 144,
    required this.onTap,
    this.isTodayPlan = false,
    this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w(width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.topRight,
            width: w(width),
            height: h(height),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(h(10)),
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
            child: isTodayPlan == false
                ? SizedBox()
                : Container(
                    margin: gapOnly(top: 8, right: 8),
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      shape: BoxShape.circle,
                    ),
                    padding: gapAll(6),
                    child: switch (mealType) {
                      "Breakfast" => SvgPicture.asset(
                        AppAssets.breakfastSvg,
                        color: Colors.black,
                      ),
                      "Lunch" => SvgPicture.asset(
                        AppAssets.lunchSvg,
                        color: Colors.black,
                      ),
                      "Dinner" => SvgPicture.asset(
                        AppAssets.dinnerSvg,
                        color: Colors.black,
                      ),
                      _ => const Icon(Icons.fastfood, color: Colors.white),
                    },
                  ),
          ),
          SizedBox(
            width: w(width),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h(14)),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
                SizedBox(height: h(10)),
                Text(
                  description,
                  maxLines: 2,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: const Color(0xff787878),
                  ),
                ),
                SizedBox(height: h(10)),
                GenericButtonWidget(onPressed: onTap, text: "View Recipe"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
