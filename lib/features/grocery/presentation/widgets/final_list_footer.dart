import 'package:flutter/material.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_segmented_progress_bar_widget.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/share_button.dart';

class FinalListFooter extends StatelessWidget {
  final String shareString;
  final int totalItems;
  final int completedItems;

  const FinalListFooter({
    super.key,
    required this.totalItems,
    required this.completedItems,
    required this.shareString,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$completedItems/$totalItems items completed",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        gap(height: 20),
        SegmentedProgressBar(total: totalItems, completed: completedItems),
        gap(height: 20),
        ShareButton(shareString: shareString),
      ],
    );
  }
}
