// ignore_for_file: prefer_final_fields, use_build_context_synchronously
// Mutable recipe-generation state; navigation after generation futures.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/ads/ad_service.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/recipe_limit/recipe_limit_service.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_recipe_is_under_progress_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/bottom_sheet/add_filter_bottom_sheet.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/generated_recipes_section.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/saved_recipes_section.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/search_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

part 'generate_recipes_page_part.dart';

class GenerateRecipesPage extends StatefulWidget {
  final String selectedDate;
  final String selectedMealType;
  final bool isPlan;
  final bool isEdit;

  const GenerateRecipesPage({
    super.key,
    required this.selectedDate,
    required this.selectedMealType,
    required this.isPlan,
    required this.isEdit,
  });

  @override
  State<GenerateRecipesPage> createState() => _GenerateRecipesPageState();
}

class _GenerateRecipesPageState extends State<GenerateRecipesPage> {
  late final PlannerBloc _plannerBloc;
  late final UserCubit _userCubit;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _caloriesFilter = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minController = TextEditingController();

  double _sliderValue = 30;

  @override
  void initState() {
    super.initState();
    _userCubit = context.read<UserCubit>();
    _plannerBloc = context.read<PlannerBloc>();
    _updateTimeFormatters(_sliderValue);
    _fetchFavouriteRecipes();
  }

  void _fetchFavouriteRecipes() {
    _plannerBloc.add(ClearAiGeneratedRecipes());
    _plannerBloc.add(
      GetFavouriteRecipesEvent(_userCubit.state.activeKitchenId),
    );
  }

  void _updateTimeFormatters(double value) {
    final hours = value ~/ 60;
    final minutes = (value % 60).round();
    _hoursController.text = "$hours hour";
    _minController.text = "$minutes min";
  }

  Future<void> _generateRecipes() async {
    final kitchenId = _userCubit.state.activeKitchenId;

    if (kitchenId.isEmpty) {
      AppToast.show("Please join a kitchen first!", ToastType.warning);
      return;
    }
    if (_searchController.text.isEmpty) {
      AppToast.show("Search field is required!", ToastType.warning);
      return;
    }

    final isSubscribed = context.read<UserCubit>().state.hasPremiumAccess;

    if (!isSubscribed) {
      bool canSearch = await RecipeLimitService.canSearchRecipe();

      if (!canSearch) {
        showAdLoadingDialog(context);

        return;
      } else {
        showAdLoadingDialog(context);
      }
    }

    _plannerBloc.add(
      GenerateRecipesEvent(
        instructions: _buildRecipePrompt(),
        kitchenId: kitchenId,
      ),
    );
  }

  void showAdLoadingDialog(BuildContext context) async {
    _plannerBloc.add(
      GenerateRecipesEvent(
        instructions: _buildRecipePrompt(),
        kitchenId: context.read<UserCubit>().state.activeKitchenId,
      ),
    );
    AdService.instance.loadAndShowInterstitial(
      context: context,
      onDismissed: () {},
    );
  }

  String _buildRecipePrompt() {
    return "You are a professional chef assistant. Generate a list of detailed recipes related to '${_searchController.text}'. "
        "Each recipe must contain approximately ${_caloriesFilter.text} calories "
        "and can be prepared within ${_hoursController.text} hour(s) and ${_minController.text} minute(s). "
        "Only include recipes that meet both the calorie and time limits.\n\n"
        "Each recipe should be structured as follows:\n"
        "1. Recipe Name\n"
        "2. Short Description\n"
        "3. Ingredients (list format with quantities)\n"
        "4. Step-by-Step Instructions\n"
        "5. Estimated Cooking Time\n"
        "6. Total Calories\n"
        "7. Serving Size\n"
        "8. Tips or Variations (optional)\n\n"
        "Ensure the recipes are clear, easy to follow, and suitable for home cooking. "
        "Avoid filler text and only provide relevant recipe information.";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: buildGenerateRecipesAppBar(),
      body: BlocConsumer<PlannerBloc, PlannerState>(
        listener: _handleStateChanges,
        builder: (context, state) => buildGenerateRecipesBody(state),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, PlannerState state) {
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      AppToast.show(state.errorMessage!, ToastType.error);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _caloriesFilter.dispose();
    _hoursController.dispose();
    _minController.dispose();
    super.dispose();
  }
}
