import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapOnly(left: 20, right: 20, bottom: 0, top: 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            gap(height: 14),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xffF6A500).withOpacity(0.85),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(AppAssets.premiumBg),
                  fit: BoxFit.cover,
                  opacity: 0.4,
                ),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffDE7600),
                  disabledBackgroundColor: AppColors.disabledPrimaryColor,
                ),
                onPressed: () {
                  context.push(Routes.scanMeal);
                },
                child: Text(
                  "Scan Receipt",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: t(12),
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            gap(height: 14),
            PantrySection(state: state),
            gap(height: 14),
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
                    "is_edit": false,
                  },
                );
              },
            ),
            gap(height: 14),
            SmartCartTile(
              infoText: state.groceryList.length > 3
                  ? "+${state.groceryList.length - 3} tap to see more"
                  : null,
              isGenerated: isGeneratedRecipes,
              previewItems: state.groceryList.take(3).toList(),
              onGenerate: onGeneratePressed,
            ),
            gap(height: 14),
            if (state.dateBasedPlan.isNotEmpty) const TonightRecipeWidget(),
            gap(height: 14),
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
    padding: gapOnly(left: 20, right: 20, bottom: 20, top: 14),
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
