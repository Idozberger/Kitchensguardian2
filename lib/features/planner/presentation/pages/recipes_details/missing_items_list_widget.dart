import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/entities/pantry.dart';
import 'package:foodkitchen/core/common/entities/pantry_item.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_checktile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/planner/domain/entities/ingredient_entity.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_bloc.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_event.dart';
import 'package:foodkitchen/features/planner/presentation/bloc/planner_state.dart';
import 'package:go_router/go_router.dart';

class MissingItemsListWidget extends StatefulWidget {
  final List<IngredientEntity> ingredients;
  const MissingItemsListWidget({super.key, required this.ingredients});

  @override
  State<MissingItemsListWidget> createState() => _MissingItemsListWidgetState();
}

class _MissingItemsListWidgetState extends State<MissingItemsListWidget> {
  late PlannerBloc plannerBloc;
  late UserCubit userCubit;
  List<IngredientEntity> selectedIngredients = [];

  @override
  void initState() {
    plannerBloc = context.read<PlannerBloc>();
    userCubit = context.read<UserCubit>();
    selectAllIngredients();
    super.initState();
  }

  void updateSelectedIngredients(IngredientEntity ingredient) {
    if (selectedIngredients.contains(ingredient)) {
      selectedIngredients.remove(ingredient);
    } else {
      selectedIngredients.add(ingredient);
    }
    setState(() {});
  }

  void selectAllIngredients() {
    selectedIngredients = [];
    for (var i = 0; i < widget.ingredients.length; i++) {
      selectedIngredients.add(widget.ingredients[i]);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlannerBloc, PlannerState>(
      builder: (_, state) {
        return UpperTile(
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
                  TextButton(
                    onPressed: () {
                      if (selectedIngredients.length ==
                          widget.ingredients.length) {
                        AppToast.show(
                          "All items are already selected",
                          ToastType.success,
                        );
                      } else {
                        selectAllIngredients();
                      }
                    },
                    child: Text(
                      "Select All",
                      style: Theme.of(context).textTheme.headlineLarge!
                          .copyWith(
                            color: AppColors.primaryColor,
                            fontSize: t(14),
                          ),
                    ),
                  ),
                ],
              ),
              Column(
                children: List.generate(widget.ingredients.length, (int index) {
                  var item = widget.ingredients[index];
                  return Padding(
                    padding: gapOnly(top: 12),
                    child: GenericCircleCheckboxTile(
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
              SizedBox(height: h(20)),
              GenericButtonWidget(
                isLoading: state.isLoading,
                onPressed: () => onAddInList(),
                text: "Add in List",
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> onAddInList() async {
    List<PantryItemEntity> requestingItems = [];
    for (var i = 0; i < selectedIngredients.length; i++) {
      requestingItems.add(
        PantryItemEntity(
          name: selectedIngredients[i].name,
          quantity: double.parse(selectedIngredients[i].amount),
          unit: selectedIngredients[i].unit,
          group: "group",
          expireDate: "",
        ),
      );
    }

    final pantryModel = Pantry(
      kitchenId: userCubit.state.activeKitchenId,
      items: requestingItems,
    );

    plannerBloc.add(RequestMissingItemsEvent(pantry: pantryModel));
  }
}
