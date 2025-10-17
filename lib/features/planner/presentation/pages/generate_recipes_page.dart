import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/data/model/meal_type_model.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/logs.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/pages/planner_page.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipes_tile.dart';
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
  late PlannerBloc plannerBloc;
  final TextEditingController searchController = TextEditingController();
  int selectedIndex = 0;
  @override
  void initState() {
    plannerBloc = context.read<PlannerBloc>();
    plannerBloc.add(ClearAiGeneratedRecipes());
    getFavouriteRecipes();
    super.initState();
  }

  void getFavouriteRecipes() async {
    plannerBloc.add(GetFavouriteRecipesEvent());
  }

  void generateRecipes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final kitchenId = prefs.getString("kitchen_id");

    if (kitchenId == null || kitchenId.isEmpty) {
      AppToast.show(
        "Looks like you haven’t joined a kitchen yet. Join one to get started!",
        ToastType.warning,
      );
      return;
    }

    if (searchController.text.isEmpty) {
      AppToast.show("Search field is required!", ToastType.warning);
      return;
    }

    plannerBloc.add(
      GenerateRecipesEvent(
        instructions: searchController.text,
        kitchenId: kitchenId,
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: BlocConsumer<PlannerBloc, PlannerState>(
        listener: (context, state) {},
        builder: (_, state) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: gapSymmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    AppTextField(
                      fillColor: Colors.white,
                      isFilled: true,
                      isLabled: false,
                      label: "",
                      suffixIcon: GestureDetector(
                        onTap: () => generateRecipes(),
                        child: Padding(
                          padding: gapAll(h(6)),
                          child: CircleAvatar(
                            backgroundColor: AppColors.primaryColor,
                            child: SvgPicture.asset(
                              AppAssets.searchSvg,
                              color: Colors.black,
                              height: h(15),
                            ),
                          ),
                        ),
                      ),
                      hintText: "e.g Fries",
                      controller: searchController,
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
                    else
                      Column(
                        children: [
                          state.recipes == null || state.recipes!.isEmpty
                              ? SizedBox()
                              : Padding(
                                  padding: EdgeInsets.only(top: h(20)),
                                  child: UpperTile(
                                    widget: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Generated Recipes",
                                          style: Theme.of(
                                            context,
                                          ).textTheme.headlineLarge,
                                        ),
                                        gap(height: 14),
                                        state.favouriteRecipes == null
                                            ? Text(
                                                "Not found, please try again.",
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.headlineLarge,
                                              )
                                            : ListView.separated(
                                                shrinkWrap: true,
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    state.recipes!.length,
                                                separatorBuilder: (_, __) =>
                                                    gap(height: 6),
                                                itemBuilder: (context, index) {
                                                  final recipe =
                                                      state.recipes![index];
                                                  return RecipeTile(
                                                    onTap: () {
                                                      var updatedRecipe =
                                                          (recipe as MealTypeModel).copyWith(
                                                            formatedDateString:
                                                                widget
                                                                    .selectedDate,
                                                            mealType: widget
                                                                .selectedMealType,
                                                          );
                                                      logError(
                                                        updatedRecipe.toJson(),
                                                      );
                                                      context.pushNamed(
                                                        Routes
                                                            .generateRecipesDetails,
                                                        extra: {
                                                          "meal_type_entity":
                                                              updatedRecipe,
                                                          "is_plan":
                                                              widget.isPlan,
                                                        },
                                                      );
                                                    },
                                                    title: recipe.title
                                                        .toString(),
                                                    subtitle: recipe
                                                        .recipeShortSummary
                                                        .toString(),
                                                    imagePath: AppAssets
                                                        .onBoardingSliderBg01,
                                                    trailingIcon: AppAssets
                                                        .arrowForwardAndroidSvg,
                                                    errorText:
                                                        recipe.missingItems
                                                        ? "Some items are missing"
                                                        : "",
                                                    selected: false,
                                                    onTrailingTap: () {
                                                      var updatedRecipe =
                                                          (recipe as MealTypeModel).copyWith(
                                                            formatedDateString:
                                                                widget
                                                                    .selectedDate,
                                                            mealType: widget
                                                                .selectedMealType,
                                                          );
                                                      logError(
                                                        updatedRecipe.toJson(),
                                                      );
                                                      context.pushNamed(
                                                        Routes
                                                            .generateRecipesDetails,
                                                        extra: {
                                                          "meal_type_entity":
                                                              updatedRecipe,
                                                          "is_plan":
                                                              widget.isPlan,
                                                        },
                                                      );
                                                    },
                                                  );
                                                },
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                          gap(height: 20),

                          UpperTile(
                            widget: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your Saved Recipes",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineLarge,
                                ),
                                gap(height: 14),
                                state.favouriteRecipes == null
                                    ? Text(
                                        "No Saved Recipes here! Try Generating one...",
                                        style: Theme.of(
                                          context,
                                        ).textTheme.headlineLarge,
                                      )
                                    : ListView.separated(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:
                                            state.favouriteRecipes!.length,
                                        separatorBuilder: (_, __) =>
                                            gap(height: 10),
                                        itemBuilder: (context, index) {
                                          var recipe =
                                              state.favouriteRecipes![index];
                                          return RecipeTile(
                                            onTap: () {
                                              var updatedRecipe =
                                                  (recipe as MealTypeModel)
                                                      .copyWith(
                                                        formatedDateString:
                                                            widget.selectedDate,
                                                        mealType: widget
                                                            .selectedMealType,
                                                      );
                                              context.pushNamed(
                                                Routes.generateRecipesDetails,
                                                extra: {
                                                  "meal_type_entity":
                                                      updatedRecipe,
                                                  "is_plan": widget.isPlan,
                                                },
                                              );
                                            },
                                            title: recipe.title.toString(),
                                            subtitle: recipe.recipeShortSummary
                                                .toString(),
                                            imagePath:
                                                AppAssets.onBoardingSliderBg01,
                                            trailingIcon: AppAssets
                                                .arrowForwardAndroidSvg,
                                            errorText: recipe.missingItems
                                                ? "Some items are missing"
                                                : "",
                                            selected: false,
                                            onTrailingTap: () {
                                              var updatedRecipe =
                                                  (recipe as MealTypeModel)
                                                      .copyWith(
                                                        formatedDateString:
                                                            widget.selectedDate,
                                                        mealType: widget
                                                            .selectedMealType,
                                                      );
                                              context.pushNamed(
                                                Routes.generateRecipesDetails,
                                                extra: {
                                                  "meal_type_entity":
                                                      updatedRecipe,
                                                  "is_plan": widget.isPlan,
                                                },
                                              );
                                            },
                                          );
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
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
      title: Text(
        "Generate Recipes",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
