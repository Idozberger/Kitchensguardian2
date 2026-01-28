import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';

class PlannerEmptyState extends StatelessWidget {
  const PlannerEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: EmptyStateWidget(
        context,
        imagePath: AppAssets.noKitchenFound,
        title: 'No meal found here',
      ),
    );
  }
}
