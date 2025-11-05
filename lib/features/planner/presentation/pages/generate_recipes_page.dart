import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
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

class GenerateRecipesPage extends StatefulWidget {
  final String selectedDate;
  final String selectedMealType;
  final bool isPlan;

  const GenerateRecipesPage({
    super.key,
    required this.selectedDate,
    required this.selectedMealType,
    required this.isPlan,
  });

  @override
  State<GenerateRecipesPage> createState() => _GenerateRecipesPageState();
}

class _GenerateRecipesPageState extends State<GenerateRecipesPage> {
  late final PlannerBloc plannerBloc;
  late final UserCubit userCubit;
  final TextEditingController searchController = TextEditingController();
  final TextEditingController caloriesFilter = TextEditingController();
  TextEditingController hoursController = TextEditingController();
  TextEditingController minController = TextEditingController();
  double sliderValue = 30;

  @override
  void initState() {
    super.initState();
    userCubit = context.read<UserCubit>();
    plannerBloc = context.read<PlannerBloc>();
    hourMinFormatter(sliderValue);
    fetchFavourites();
  }

  void fetchFavourites() {
    plannerBloc.add(ClearAiGeneratedRecipes());
    plannerBloc.add(GetFavouriteRecipesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context, caloriesFilter),
      body: BlocConsumer<PlannerBloc, PlannerState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            AppToast.show(state.errorMessage!, ToastType.error);
          }
        },
        builder: (_, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: gapSymmetric(horizontal: 20, vertical: 14),
              child: Column(
                children: [
                  if (state.startedRecipe.isNotEmpty)
                    RecipeInProgressNotification(
                      onCancelRecipe: () {
                        plannerBloc.add(
                          UpdateStartRecipeEvent(
                            startRecipe: false,
                            mealTypeEntity: [],
                            doneSteps: [],
                          ),
                        );
                      },
                      padding: gapOnly(bottom: 14),
                      canCancel: true,
                      mealTypeEntity: state.startedRecipe[0],
                    ),
                  SearchBarWidgetForGenerateRecipes(
                    controller: searchController,
                    onSearchTap: _generateRecipes,
                  ),
                  if (state.isLoading)
                    Padding(
                      padding: gapOnly(top: 18),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    )
                  else ...[
                    if (state.recipes != null && state.recipes!.isNotEmpty)
                      gap(height: 14),
                    GeneratedRecipesSection(
                      state: state,
                      selectedDate: widget.selectedDate,
                      selectedMealType: widget.selectedMealType,
                      isPlan: widget.isPlan,
                    ),
                    gap(height: 14),
                    SavedRecipesSection(
                      state: state,
                      selectedDate: widget.selectedDate,
                      selectedMealType: widget.selectedMealType,
                      isPlan: widget.isPlan,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, TextEditingController controller) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () {
              plannerBloc.add(GetDateBasedPlans(formatDate(DateTime.now())));
              context.pop();
            },
          ),
        ],
      ),
      actions: [
        CircularIconButton(
          iconAsset: AppAssets.filterSvg,

          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              barrierColor: Colors.black.withOpacity(0.4),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) {
                return BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),

                    child: AddFilterBottomSheet(
                      controller: controller,
                      sliderValue: sliderValue,
                      hoursController: hoursController,
                      minController: minController,
                      onChanged: (double value) => hourMinFormatter(value),

                      callback: () {
                        final text = controller.text.trim();
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
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
        gap(width: 20),
      ],
      title: Text(
        "Generate Recipes",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  void hourMinFormatter(double value) {
    final hours = (value ~/ 60);
    final minutes = (value % 60).round();

    hoursController.text = "$hours hour";
    minController.text = "$minutes min";
  }

  Future<void> _generateRecipes() async {
    final kitchenId = userCubit.state.activeKitchenId;

    if (kitchenId.isEmpty) {
      AppToast.show("Please join a kitchen first!", ToastType.warning);
      return;
    }
    if (searchController.text.isEmpty) {
      AppToast.show("Search field is required!", ToastType.warning);
      return;
    }

    plannerBloc.add(
      GenerateRecipesEvent(
        instructions:
            "You are a professional chef assistant. Generate a list of detailed recipes related to '${searchController.text}'. "
            "Each recipe must contain approximately ${caloriesFilter.text} calories "
            "and can be prepared within ${hoursController.text} hour(s) and ${minController.text} minute(s). "
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
            "Avoid filler text and only provide relevant recipe information.",
        kitchenId: kitchenId,
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
