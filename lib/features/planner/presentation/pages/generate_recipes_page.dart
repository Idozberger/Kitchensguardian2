import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/generated_recipes_section.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/saved_recipes_section.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/search_bar.dart';

import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final TextEditingController searchController = TextEditingController();
  final TextEditingController caloriesFilter = TextEditingController();

  @override
  void initState() {
    super.initState();
    plannerBloc = context.read<PlannerBloc>();
    plannerBloc.add(ClearAiGeneratedRecipes());
    plannerBloc.add(GetFavouriteRecipesEvent());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _generateRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final kitchenId = prefs.getString("kitchen_id");

    if (kitchenId == null || kitchenId.isEmpty) {
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
            "${searchController.text} generate recipes only that have ${caloriesFilter.text} calories}",
        kitchenId: kitchenId,
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
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.black),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              backgroundColor: Colors.white,
              isScrollControlled: true,
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),

                  child: SingleChildScrollView(
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Add Filters",
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(color: Colors.black),
                            ),
                            gap(height: 8),
                            Text(
                              "Add a calorie filter to guide the AI in generating recipes that match your calorie preference.",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            gap(height: 12),
                            Row(
                              children: [
                                const Text("Estimated"),
                                SizedBox(width: w(5)),
                                Image.asset(
                                  AppAssets.crownImage,
                                  height: h(22),
                                ),
                              ],
                            ),
                            gap(height: 10),
                            AppTextField(
                              hintText: "calories, 450",
                              isLabled: false,
                              fillColor: Colors.white,
                              isFilled: true,
                              controller: controller,
                              label: '',
                            ),
                            gap(height: 14),
                            GenericButtonWidget(
                              onPressed: () {
                                final text = controller.text.trim();
                                if (text.isEmpty) {
                                  AppToast.show(
                                    "Please enter a filter value before adding.",
                                    ToastType.warning,
                                  );
                                } else {
                                  AppToast.show(
                                    "Filter applied",
                                    ToastType.success,
                                  );
                                  context.pop();
                                }
                              },
                              text: "Add Filter",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
        gap(width: 8),
      ],
      title: Text(
        "Generate Recipes",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context, caloriesFilter),
      body: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (_, state) {
          return SafeArea(
            child: SingleChildScrollView(
              padding: gapSymmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  SearchBarWidgetForGenerateRecipes(
                    controller: searchController,
                    onSearchTap: _generateRecipes,
                  ),
                  if (state.isLoading)
                    Padding(
                      padding: gapOnly(top: 40),
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
}
