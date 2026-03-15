import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_checktile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_bloc.dart';
import 'package:foodkitchen/features/pantry/presentation/models/pantry_items.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:go_router/go_router.dart';

class MissingItemsListWidget extends StatefulWidget {
  final bool isPlanned;
  final String recipeId;
  final String id;

  const MissingItemsListWidget({
    super.key,
    required this.isPlanned,
    required this.recipeId,
    required this.id,
  });

  @override
  State<MissingItemsListWidget> createState() => _MissingItemsListWidgetState();
}

class _MissingItemsListWidgetState extends State<MissingItemsListWidget> {
  late PlannerBloc plannerBloc;
  late HomeBloc homeBloc;
  late UserCubit userCubit;
  List<IngredientEntity> selectedIngredients = [];

  @override
  void initState() {
    plannerBloc = context.read<PlannerBloc>();
    userCubit = context.read<UserCubit>();
    homeBloc = context.read<HomeBloc>();
    super.initState();
  }

  List<IngredientEntity> getIngredients(PlannerState state) {
    final allRecipes = [
      ...state.recipes ?? [],
      ...state.favouriteRecipes ?? [],
      ...state.startedRecipe,
    ];

    for (final recipe in allRecipes) {
      if (recipe.recipeId == widget.recipeId || recipe.id == widget.recipeId) {
        return recipe.missingIngredients;
      }
    }

    for (final weeklyPlan in state.getAllWeeklyPlans) {
      final breakfast = weeklyPlan.breakfast;
      if (breakfast != null && breakfast.id == widget.recipeId) {
        log("Recipe Name: ${breakfast.title}");
        return breakfast.missingIngredients;
      }

      final lunch = weeklyPlan.lunch;
      if (lunch != null && lunch.id == widget.recipeId) {
        return lunch.missingIngredients;
      }

      final dinner = weeklyPlan.dinner;
      if (dinner != null && dinner.id == widget.recipeId) {
        return dinner.missingIngredients;
      }
    }
    for (final recipe in homeBloc.state.suggestedRecipe) {
      if (recipe.id == widget.recipeId) {
        return recipe.missingIngredients;
      }
    }

    return [];
  }

  void updateSelectedIngredients(IngredientEntity ingredient) {
    if (selectedIngredients.contains(ingredient)) {
      selectedIngredients.remove(ingredient);
    } else {
      selectedIngredients.add(ingredient);
    }
    setState(() {});
  }

  void selectAllIngredients(List<IngredientEntity> ingredients) {
    selectedIngredients = List.from(ingredients);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (_, state) {
        final ingredients = getIngredients(state);

        return ingredients.isEmpty
            ? UpperTile(
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Ingredients Available',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    gap(height: 8),
                    Text(
                      'You have everything needed to prepare this recipe.',

                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              )
            : UpperTile(
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Missing Items",
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        ingredients.isEmpty
                            ? SizedBox()
                            : TextButton(
                                onPressed: () {
                                  if (selectedIngredients.length ==
                                      ingredients.length) {
                                    setState(() => selectedIngredients = []);
                                  } else {
                                    selectAllIngredients(ingredients);
                                  }
                                },
                                child: Text(
                                  selectedIngredients.length ==
                                          ingredients.length
                                      ? "Deselect All"
                                      : "Select All",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge!
                                      .copyWith(
                                        color: AppColors.primaryColor,
                                        fontSize: t(14),
                                      ),
                                ),
                              ),
                      ],
                    ),
                    ingredients.isEmpty
                        ? Padding(
                            padding: gapOnly(top: 8),
                            child: Text(
                              "No ingredients are available",
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          )
                        : Column(
                            children: List.generate(ingredients.length, (
                              int index,
                            ) {
                              var item = ingredients[index];
                              return Padding(
                                padding: gapOnly(top: 8),
                                child: GenericCircleCheckboxTile(
                                  unit: item.unit,
                                  quantity: item.amount,
                                  title: item.name,
                                  isChecked: selectedIngredients.contains(item),
                                  isFinalList: false,
                                  activeColor: AppColors.primaryColor,
                                  onChanged: (Object? value) {
                                    updateSelectedIngredients(item);
                                  },
                                ),
                              );
                            }),
                          ),
                    ingredients.isEmpty
                        ? const SizedBox.shrink()
                        : SizedBox(height: h(20)),
                    ingredients.isEmpty
                        ? const SizedBox.shrink()
                        : Row(
                            spacing: w(6),
                            children: [
                              Flexible(
                                child: GenericButtonWidget(
                                  isOutlined: true,
                                  isLoading: state.isLoading,
                                  onPressed: () => onAddInList(),
                                  text: "Add to grocery list",
                                ),
                              ),

                              Flexible(
                                child: GenericButtonWidget(
                                  isLoading: state.addingToInventory,
                                  onPressed: () => onAddInInventory(
                                    context.read<UserCubit>().state.role ==
                                        "member",
                                  ),
                                  text:
                                      (context.read<UserCubit>().state.role ==
                                          "member")
                                      ? "Request Items"
                                      : "Add to Inventory",
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              );
      },
    );
  }

  Future<void> onAddInInventory(bool isMember) async {
    if (selectedIngredients.isEmpty) {
      AppToast.show("Please select at least one item", ToastType.warning);
      return;
    }

    List<PantryItem> pantryItems = [];

    for (var ingredient in selectedIngredients) {
      pantryItems.add(
        PantryItem(
          nameController: TextEditingController(text: ingredient.name),
          qtyController: TextEditingController(text: ingredient.amount),
          manuFacturingDate: TextEditingController(text: ""),
          expireDate: TextEditingController(text: ""),
          unit: ingredient.unit,
          pantry: null,
          file: null,
          fileBytes: null,
        ),
      );
    }

    context.pushNamed(
      Routes.addItem,
      extra: {
        "pantryItems": pantryItems,
        "addToInventory": true,
        "isMember": isMember,
        "recipeId": widget.recipeId,
        "selectedIngredients": selectedIngredients,
      },
    );
    setState(() => selectedIngredients = []);
  }

  Future<void> onAddInList() async {
    if (selectedIngredients.isEmpty) {
      AppToast.show("Please select at least one item", ToastType.warning);
      return;
    }

    List<PantryItemEntity> requestingItems = [];
    for (var i = 0; i < selectedIngredients.length; i++) {
      requestingItems.add(
        PantryItemEntity(
          name: selectedIngredients[i].name,
          quantity: double.tryParse(selectedIngredients[i].amount) ?? 1,
          unit: selectedIngredients[i].unit,
          group: "group",
          expireDate: "",
          thumbnail: "",
          expiryStatus: '',
          stockStatus: '',
          itemId: '',
        ),
      );
    }

    final pantryModel = Pantry(
      kitchenId: userCubit.state.activeKitchenId,
      items: requestingItems,
    );

    plannerBloc.add(
      RequestMissingItemsEvent(
        pantry: pantryModel,
        isPlan: widget.isPlanned,
        recipeId: widget.recipeId,
        selectedIngredients: selectedIngredients,
      ),
    );

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      selectedIngredients = [];
    });
  }
}
