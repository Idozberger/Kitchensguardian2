import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

class RecipeCard extends StatelessWidget {
  final double width;
  final double height;
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.width = 258,
    this.height = 144,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w(width),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
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
