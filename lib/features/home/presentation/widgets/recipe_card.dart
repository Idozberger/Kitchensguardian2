import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

class RecipeCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: w(257),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: w(257),
            height: h(145),
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
            width: w(257),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: h(15)),
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
