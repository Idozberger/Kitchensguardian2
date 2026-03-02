import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: w(48), color: Colors.grey[300]),
          gap(height: 12),
          Text(
            "No requests found",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: t(14),
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
