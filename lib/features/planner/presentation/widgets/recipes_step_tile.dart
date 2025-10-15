import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class RecipeStepTile extends StatelessWidget {
  final String stepText;
  final bool isCompleted;
  final VoidCallback callback;

  const RecipeStepTile({
    super.key,
    required this.stepText,
    required this.isCompleted,
    required this.callback,
  });

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: w(18),
            height: h(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryColor, width: 2),
              color: isCompleted ? AppColors.primaryColor : Colors.transparent,
            ),
            child: isCompleted
                ? Icon(Icons.check, size: h(10), color: Colors.white)
                : null,
          ),
          SizedBox(width: w(10)),
          Flexible(
            child: Text(
              stepText,
              style: Theme.of(context).textTheme.headlineMedium!,
            ),
          ),
        ],
      ),
    );
  }
}
