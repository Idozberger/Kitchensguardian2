import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/entities/meal_type_entity.dart';

import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

class IngredientsListWidget extends StatelessWidget {
  final MealTypeEntity recipe;

  const IngredientsListWidget({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Available Items",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          gap(height: 13),
          ...recipe.ingredients.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: h(13)),
              child: Text(
                "${item.amount} ${item.unit} ${item.name}",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
