import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_segmented_progress_bar_widget.dart';

class BottomNavRecipeDetails extends StatelessWidget {
  const BottomNavRecipeDetails({super.key, required this.steps});

  final List<Map<String, dynamic>> steps;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedProgressBar(
                total: steps.length,
                completed: steps
                    .where((step) => step["completed"] == true)
                    .length,
              ),
              gap(height: 6),
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  "${steps.where((step) => step["completed"] == true).length}/${steps.length}",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall!.copyWith(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
