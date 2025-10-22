import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/widgets/action_tile.dart';
import 'package:foodkitchen/features/home/presentation/widgets/create_or_join_tile.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/home/presentation/widgets/pantry_section.dart';
import 'package:foodkitchen/features/home/presentation/widgets/smart_cart.dart';
import 'package:foodkitchen/features/home/presentation/widgets/tonight_recipe.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class KitchenHomeView extends StatelessWidget {
  final HomeState state;
  final bool isGeneratedRecipes;
  final VoidCallback onGeneratePressed;

  const KitchenHomeView({
    super.key,
    required this.state,
    required this.isGeneratedRecipes,
    required this.onGeneratePressed,
  });
  static const List<String> demoIngredients = [
    "Tomatoes",
    "Olive Oil",
    "Garlic",
    "Onions",
    "Cheese",
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapOnly(left: 20, right: 20, bottom: 20, top: 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            gap(height: 15),
            PantrySection(state: state),
            gap(height: 15),
            ActionTile(
              title: "Find Recipes",
              buttonText: "Find Recipes",
              svgPath: AppAssets.findRecipesSvg,
              onTap: () {
                final date = DateFormat('dd/MM/yyyy').format(DateTime.now());
                context.pushNamed(
                  Routes.generateRecipes,
                  extra: {
                    "selected_date": date,
                    "selected_meal_type": "Breakfast",
                    "is_plan": false,
                  },
                );
              },
            ),
            gap(height: 15),
            SmartCartTile(
              infoText: demoIngredients.length > 3
                  ? "+${demoIngredients.length - 3} more"
                  : null,
              isGenerated: isGeneratedRecipes,
              previewItems: demoIngredients.take(3).toList(),
              onGenerate: onGeneratePressed,
            ),
            gap(height: 15),
            if (state.dateBasedPlan.isNotEmpty) const TonightRecipeWidget(),
          ],
        ),
      ),
    );
  }
}

class NoKitchenView extends StatelessWidget {
  const NoKitchenView({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: gapOnly(left: 20, right: 20, bottom: 20, top: 10),
    child: Column(
      children: [
        const CreateOrJoinKitchenTile(),
        gap(height: 140),
        EmptyStateWidget(
          context,
          imagePath: AppAssets.noKitchenFound,
          title: 'No Kitchen found',
        ),
      ],
    ),
  );
}
