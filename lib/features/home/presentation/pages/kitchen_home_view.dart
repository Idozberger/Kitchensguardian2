// ignore_for_file: use_build_context_synchronously, unnecessary_underscores
// Async navigation after kitchen loads; legacy underscore locals in large widget.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/ads/ad_service.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/document_scanning/document_scanning_service.dart';
import 'package:foodkitchen/core/services/recipe_limit/recipe_limit_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/show_recipe_generation_limit_dialog.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/widgets/action_tile.dart';
import 'package:foodkitchen/features/home/presentation/widgets/create_or_join_tile.dart';
import 'package:foodkitchen/features/home/presentation/widgets/items_request_section.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/home/presentation/widgets/pantry_section.dart';
import 'package:foodkitchen/features/home/presentation/widgets/smart_cart.dart';
import 'package:foodkitchen/features/home/presentation/widgets/suggestion_recipes.dart';
import 'package:foodkitchen/features/home/presentation/widgets/tonight_recipe.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/custom_appbar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';

part 'kitchen_home_view_part.dart';

class KitchenHomeView extends StatefulWidget {
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
  State<KitchenHomeView> createState() => _KitchenHomeViewState();
}

class _KitchenHomeViewState extends State<KitchenHomeView>
    with _KitchenHomeViewScanAndRecipes {
  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Padding(
      padding: gapOnly(left: 20, right: 20, bottom: 0, top: 0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            gap(height: 14),
            _buildScanReceiptButton(context),
            if (state.itemsRequest.isNotEmpty) ...[
              gap(height: 12),
              ItemRequestSection(state: state),
            ],
            gap(height: 12),

            PantrySection(state: state),
            gap(height: 12),
            _buildFindRecipesButton(context),
            gap(height: 12),
            _buildGrocerySection(),
            gap(height: 12),
            _buildRecipeSuggestionsSection(state),
            gap(height: 12),
            _buildTonightRecipeSection(state),
            gap(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildGrocerySection() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: SmartCartTile(onGenerate: widget.onGeneratePressed),
    );
  }

  Widget _buildRecipeSuggestionsSection(HomeState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: state.loadingRecipeSuggestion
          ? _buildSuggestionShimmer()
          : state.suggestedRecipe.isNotEmpty
          ? const SuggestionRecipes()
          : const SizedBox.shrink(),
    );
  }

  Widget _buildTonightRecipeSection(HomeState state) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: state.loadingWeeklyPlans
          ? _buildTonightShimmer()
          : state.dateBasedPlan.isNotEmpty
          ? const TonightRecipeWidget()
          : const SizedBox.shrink(),
    );
  }
}

class NoKitchenView extends StatelessWidget {
  const NoKitchenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapOnly(left: 20, right: 20, bottom: 20, top: 14),
      child: Column(
        children: [
          const CreateOrJoinKitchenTile(),
          gap(height: 140),
          EmptyStateWidget(
            imagePath: AppAssets.noKitchenFound,
            title: 'No Kitchen found',
          ),
        ],
      ),
    );
  }
}
