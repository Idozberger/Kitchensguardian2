// ignore_for_file: prefer_final_fields

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
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
    _plannerBloc.add(GetFavouriteRecipesEvent());
  }

  void _updateTimeFormatters(double value) {
    final hours = (value ~/ 60);
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

    _plannerBloc.add(
      GenerateRecipesEvent(
        instructions: _buildRecipePrompt(),
        kitchenId: kitchenId,
      ),
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
      appBar: _buildAppBar(),
      body: BlocConsumer<PlannerBloc, PlannerState>(
        listener: _handleStateChanges,
        builder: (context, state) => _buildBody(state),
      ),
    );
  }

  void _handleStateChanges(BuildContext context, PlannerState state) {
    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      AppToast.show(state.errorMessage!, ToastType.error);
    }
  }

  Widget _buildBody(PlannerState state) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: gapSymmetric(horizontal: 20, vertical: 14),
        child: Column(
          children: [
            if (state.startedRecipe.isNotEmpty)
              _buildRecipeInProgressNotification(state),
            _buildSearchBar(),
            if (state.isLoading)
              _buildLoadingState()
            else ...[
              if (state.recipes != null && state.recipes!.isNotEmpty)
                gap(height: 14),
              _buildGeneratedRecipesSection(state),
              gap(height: 14),
              _buildSavedRecipesSection(state),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeInProgressNotification(PlannerState state) {
    return RecipeInProgressNotification(
      onCancelRecipe: () {
        _plannerBloc.add(
          UpdateStartRecipeEvent(
            startRecipe: false,
            recipeEntity: [],
            doneSteps: [],
          ),
        );
      },
      padding: gapOnly(bottom: 14),
      canCancel: true,
      recipeEntity: state.startedRecipe[0],
    );
  }

  Widget _buildSearchBar() {
    return SearchBarWidgetForGenerateRecipes(
      controller: _searchController,
      onSearchTap: _generateRecipes,
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: gapOnly(top: 100),
      child: Lottie.asset(AppAssets.loader),
    );
  }

  Widget _buildGeneratedRecipesSection(PlannerState state) {
    return GeneratedRecipesSection(
      state: state,
      selectedDate: widget.selectedDate,
      selectedMealType: widget.selectedMealType,
      isPlan: widget.isPlan,
      isEdit: widget.isEdit,
    );
  }

  Widget _buildSavedRecipesSection(PlannerState state) {
    return SavedRecipesSection(
      state: state,
      selectedDate: widget.selectedDate,
      selectedMealType: widget.selectedMealType,
      isPlan: widget.isPlan,
      isEdit: widget.isEdit,
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      leading: _buildBackButton(),
      actions: [_buildFilterButton(), gap(width: 20)],
      title: Text(
        "Generate Recipes",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  Widget _buildBackButton() {
    return Row(
      children: [
        SizedBox(width: w(16)),
        CircularIconButton(
          iconAsset: AppAssets.backArrowiOS,
          onTap: () => context.pop(),
        ),
      ],
    );
  }

  Widget _buildFilterButton() {
    return CircularIconButton(
      iconAsset: AppAssets.filterSvg,
      onTap: _showFilterBottomSheet,
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      barrierColor: Colors.black.withOpacity(0.4),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: AddFilterBottomSheet(
            controller: _caloriesFilter,
            sliderValue: _sliderValue,
            hoursController: _hoursController,
            minController: _minController,
            onChanged: _updateTimeFormatters,
            callback: _handleFilterApplied,
          ),
        ),
      ),
    );
  }

  void _handleFilterApplied() {
    final text = _caloriesFilter.text.trim();
    if (text.isEmpty) {
      AppToast.show(
        "Please enter a filter value before adding.",
        ToastType.error,
        gravity: ToastGravity.TOP,
      );
    } else {
      AppToast.show("Filter applied", ToastType.success);
      context.pop();
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
