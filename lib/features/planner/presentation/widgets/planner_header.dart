import 'package:flutter/material.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';

class PlannerHeader extends StatelessWidget {
  final VoidCallback onAddMeal;

  const PlannerHeader({super.key, required this.onAddMeal});

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Plan your meals for the week ahead",
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          GenericButtonWidget(onPressed: onAddMeal, text: "+ Add Meal"),
        ],
      ),
    );
  }
}
