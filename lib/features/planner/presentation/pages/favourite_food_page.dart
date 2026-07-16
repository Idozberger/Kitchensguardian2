import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/reciep_entity.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/date_format_to_string.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:foodkitchen/features/planner/presentation/widgets/recipes_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

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
    plannerBloc.add(
      GetFavouriteRecipesEvent(context.read<UserCubit>().state.activeKitchenId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: BlocBuilder<PlannerBloc, PlannerState>(
        builder: (_, state) {
          return state.isLoading
              ? Center(child: Lottie.asset(AppAssets.loader))
              : state.favouriteRecipes == null ||
                    state.favouriteRecipes!.isEmpty
              ? Center(
                  child: Text(
                    "You dont have any favourite recipes",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                )
              : SafeArea(
                  child: FavouriteRecipesListView(
                    recipes: state.favouriteRecipes!,
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
                String formatedDateString = formatDate(DateTime.now());
                context.pushNamed(
                  Routes.generateRecipes,
                  extra: {
                    "selected_date": formatedDateString,
                    "selected_meal_type": "",
                    "is_plan": false,
                    "is_edit": false,
                  },
                );
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

/// Lazily-built favourite recipes list. Extracted so the `ListView.builder`
/// shape - required as favourites accumulate over time - is directly
/// testable without standing up `PlannerBloc`/`UserCubit`.
class FavouriteRecipesListView extends StatelessWidget {
  const FavouriteRecipesListView({super.key, required this.recipes});

  final List<RecipeEntity> recipes;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: gapSymmetric(horizontal: 20, vertical: 20),
      itemCount: recipes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Text(
            "Your all favorite food list",
            style: Theme.of(context).textTheme.headlineLarge,
          );
        }

        final recipe = recipes[index - 1];
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
                    "is_edit": false,
                  },
                );
              },
              title: recipe.title,
              subtitle: recipe.cookingTime,
              uint8list: recipe.thumbnail,
              trailingIcon: AppAssets.arrowForwardAndroidSvg,
              errorText: recipe.missingIngredients.isNotEmpty
                  ? "Some items are missing*"
                  : "",
              onTrailingTap: () {
                context.pushNamed(
                  Routes.generateRecipesDetails,
                  extra: {
                    "meal_type_entity": recipe,
                    "is_plan": false,
                    "is_edit": false,
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
