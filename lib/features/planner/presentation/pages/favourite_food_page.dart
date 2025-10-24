import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipes_tile.dart';
import 'package:go_router/go_router.dart';

class FavouriteFoodPage extends StatefulWidget {
  const FavouriteFoodPage({super.key});

  @override
  State<FavouriteFoodPage> createState() => _FavouriteFoodPageState();
}

class _FavouriteFoodPageState extends State<FavouriteFoodPage> {
  late PlannerBloc plannerBloc;
  @override
  void initState() {
    plannerBloc = context.read<PlannerBloc>();
    getFavouriteRecipes();
    super.initState();
  }

  void getFavouriteRecipes() async {
    plannerBloc.add(GetFavouriteRecipesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (_, state) {
          return state.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : state.favouriteRecipes == null
              ? Center(
                  child: Text(
                    "You dont have any favourite recipes",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: gapSymmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your all favorite food list",
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                          ListView.builder(
                            itemCount: state.favouriteRecipes!.length,
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              final recipe = state.favouriteRecipes![index];
                              return Padding(
                                padding: gapOnly(top: 10),
                                child: UpperTile(
                                  horizontalPadding: 8,
                                  verticalPadding: 8,
                                  widget: RecipeTile(
                                    onTap: () {
                                      context.pushNamed(
                                        Routes.generateRecipesDetails,
                                        extra: {
                                          "meal_type_entity": recipe,
                                          "is_plan": false,
                                        },
                                      );
                                    },
                                    title: recipe.title.toString(),
                                    subtitle: recipe.cookingTime.toString(),
                                    imagePath: AppAssets.onBoardingSliderBg01,
                                    trailingIcon:
                                        AppAssets.arrowForwardAndroidSvg,
                                    errorText: recipe.missingItems
                                        ? "Some items are missing*"
                                        : "",

                                    onTrailingTap: () {
                                      context.pushNamed(
                                        Routes.generateRecipesDetails,
                                        extra: {
                                          "meal_type_entity": recipe,
                                          "is_plan": false,
                                        },
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
      bottomNavigationBar: ColoredBox(
        color: const Color(0xffF9F9F9),
        child: SafeArea(
          child: Padding(
            padding: gapOnly(left: 20, right: 20, bottom: 14, top: 14),
            child: GenericButtonWidget(
              onPressed: () {
                context.push(Routes.generateRecipes);
              },
              text: "Generate More",
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      centerTitle: true,
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      title: Text(
        "Favorite Food",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
