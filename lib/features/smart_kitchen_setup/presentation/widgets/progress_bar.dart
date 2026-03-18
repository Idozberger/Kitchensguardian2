import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/kitchens/presentation/widgets/kitchen_snippet.dart';

class ProgressBar extends StatelessWidget {
  final int completedCount;
  final int total;
  final double progress;

  const ProgressBar({
    super.key,
    required this.completedCount,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sections scanned',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Color(0xFF9AA0B8),
                  fontSize: t(12),
                ),
              ),
              Text(
                '$completedCount / $total',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.black,
                  fontSize: t(12),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          gapH(8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF1A1D27),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4AE68A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
