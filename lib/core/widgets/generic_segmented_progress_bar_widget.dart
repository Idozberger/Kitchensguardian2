import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class SegmentedProgressBar extends StatelessWidget {
  final int total;
  final int completed;

  const SegmentedProgressBar({
    super.key,
    required this.total,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = total > 0 ? completed / total : 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(h(27)),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: progress),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            minHeight: h(12),
          );
        },
      ),
    );
  }
}
