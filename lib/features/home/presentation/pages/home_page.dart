import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/join_kitchen.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/dialogs/create_kitchen.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/home/presentation/widgets/recommended_recipes.dart';
import 'package:foodkitchen/features/home/presentation/widgets/rounded_text_container.dart';
import 'package:foodkitchen/features/home/presentation/widgets/tonight_recipe.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/list_tile.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> ingredients = [
    "Tomatoes",
    "Olive Oil",
    "Garlic",
    "Onions",
    "Cheese",
  ];
  bool isJoinedKitched = false;
  bool isClickedPantryAction = false;
  bool isGeneratedRecipes = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F9F9),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          AppToast.show(state.successMessage!, ToastType.success);
        }
        if (state.errorMessage != null) {
          AppToast.show(state.errorMessage!, ToastType.error);
        }
      },
      builder: (_, homeState) {
        return ListView(
          padding: gapOnly(left: 20, right: 20, bottom: 20, top: 10),
          children: [
            if (isJoinedKitched) ...[
              if (isClickedPantryAction)
                _buildTextAndButtonTile(
                  context,
                  title: "Scan to log in your food!",
                  buttonText: "Scan",
                  svgPath: AppAssets.scanSvg,
                  callback: () {
                    context.push(Routes.scanMeal);
                  },
                ),
              SizedBox(height: h(20)),

              _buildPantryTile(context),
              SizedBox(height: h(20)),
              _buildTextAndButtonTile(
                context,
                title: "Find Recipes",
                buttonText: "Find Recipes",
                svgPath: AppAssets.findRecipesSvg,
                callback: () {
                  // context.push(Routes.scanMeal);
                },
              ),
              SizedBox(height: h(20)),
              UpperTile(widget: RecommendedRecipes(), horizontalPadding: 0),
              SizedBox(height: h(20)),
              _buildSmartCartTile(context),
              if (isGeneratedRecipes) ...[
                SizedBox(height: h(20)),
                UpperTile(widget: TonightRecipeWidget(), horizontalPadding: 0),
              ],
            ],
            if (isJoinedKitched == false) ...[
              _buildHomeUpperTile(context),
              SizedBox(height: h(140)),
              EmptyStateWidget(
                context,
                imagePath: AppAssets.noKitchenFound,
                title: 'No Kitchen found',
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHomeUpperTile(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Kitchen you have to:",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          SizedBox(height: h(15)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: GenericButtonWidget(
                  isOutlined: true,
                  onPressed: () async {
                    final result = await showCreateKitchenDialog(context);

                    if (result == true || result == false) {
                      setState(() {
                        isJoinedKitched = true;
                      });
                    }
                  },
                  text: "Create",
                ),
              ),
              SizedBox(width: h(10)),
              Flexible(
                child: GenericButtonWidget(
                  onPressed: () async {
                    final result = await showJoinKitchenDialog(context);
                    if (result == true || result == false) {
                      setState(() {
                        isJoinedKitched = true;
                      });
                    }
                  },
                  text: "Join",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPantryTile(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Pantry", style: Theme.of(context).textTheme.headlineLarge),
              SvgPicture.asset(AppAssets.pantrySvg),
            ],
          ),
          SizedBox(height: h(15)),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isClickedPantryAction == false) ...[
                Flexible(
                  child: SizedBox(
                    width: double.infinity,
                    height: h(40),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push(Routes.scanMeal);
                      },
                      icon: SvgPicture.asset(AppAssets.scanSvg),
                      label: Text(
                        "Scan",
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(
                              fontSize: t(13),
                              color: AppColors.primaryColor,
                            ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: w(10)),
              ],
              Flexible(
                child: SizedBox(
                  width: double.infinity,
                  height: h(40),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(Routes.addItem);
                      setState(() {
                        isClickedPantryAction = true;
                      });
                    },
                    icon: SvgPicture.asset(AppAssets.addSvg),
                    label: Text(
                      "Add Item",
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(fontSize: t(13), color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: h(15)),
          if (isClickedPantryAction) ...[
            ListView.separated(
              itemCount: 3,
              shrinkWrap: true,

              separatorBuilder: (context, index) {
                return Padding(
                  padding: gapSymmetric(vertical: 5),
                  child: Divider(color: Color(0xffF4F4F4)),
                );
              },
              padding: gapZero,
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: ListItemWidget(
                        text: "Item ${index + 1}",
                        textStyle: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(
                              fontSize: t(13),
                              color: Color(0xff787878),
                            ),
                        crossAlignment: CrossAxisAlignment.center,
                      ),
                    ),
                    Text(
                      "${index + 1}d left",
                      style: Theme.of(context).textTheme.headlineMedium!
                          .copyWith(fontSize: t(13), color: Color(0xff787878)),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: h(15)),
            Center(
              child: SizedBox(
                width: w(178),
                height: h(35),
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(Routes.myPantry);
                  },
                  icon: SvgPicture.asset(
                    AppAssets.eyeSvg,
                    color: AppColors.primaryColor,
                    width: w(10),
                    height: h(10),
                  ),
                  label: Text(
                    "Tap to see more",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: t(13),
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
            ),
          ] else
            Text(
              "No items available in Pantry",
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: t(13),
                color: Color(0xff787878),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextAndButtonTile(
    BuildContext context, {
    required String title,
    required String buttonText,
    required String svgPath,
    required VoidCallback callback,
  }) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          gap(height: 15),
          SizedBox(
            height: h(40),
            child: ElevatedButton.icon(
              onPressed: () {
                callback();
              },
              icon: SvgPicture.asset(svgPath, color: Colors.black),
              label: Text(
                buttonText,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(13),
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartCartTile(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Smart Cart",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              SvgPicture.asset(AppAssets.pantrySvg),
            ],
          ),
          SizedBox(height: h(15)),
          if (isGeneratedRecipes)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Preview items:",
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: t(13),
                    color: Color(0xff787878),
                  ),
                ),
                SizedBox(height: h(15)),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: w(4),
                  runSpacing: w(8),
                  children: [
                    for (int i = 0; i < ingredients.length && i < 3; i++)
                      RoundedTextContainer(
                        text: ingredients[i],

                        fontWeight: FontWeight.w500,
                      ),

                    if (ingredients.length > 4)
                      RoundedTextContainer(
                        text: "+${ingredients.length - 3} more",
                      ),
                  ],
                ),
              ],
            )
          else
            Text(
              "No items available in Pantry",
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: t(13),
                color: Color(0xff787878),
              ),
            ),
          SizedBox(height: h(15)),
          GenericButtonWidget(
            onPressed: () {
              setState(() {
                isGeneratedRecipes = true;
              });
            },
            text: "Generate Grocery List",
          ),
        ],
      ),
    );
  }
}
