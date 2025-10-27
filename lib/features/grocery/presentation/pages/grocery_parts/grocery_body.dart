import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/grocery/domain/entities/requested_item.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_parts/grocery_list_item.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/category_tabs.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/final_list_footer.dart';

import 'package:foodkitchen/features/grocery/presentation/widgets/search_bar.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/show_delete_dialog.dart';
import 'package:go_router/go_router.dart';

class GroceryBody extends StatefulWidget {
  final GroceryState state;
  final UserCubit userCubit;
  final GroceryBloc groceryBloc;
  final TextEditingController controller;

  const GroceryBody({
    super.key,
    required this.state,
    required this.userCubit,
    required this.groceryBloc,
    required this.controller,
  });

  @override
  State<GroceryBody> createState() => _GroceryBodyState();
}

class _GroceryBodyState extends State<GroceryBody> {
  final List<String> requestedAndAiGeneratedSelectedList = [];
  final List<String> finalListSelectedItems = [];
  int selectedIndex = 0;
  updateIndex(int index) {
    selectedIndex = index;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroceryBloc, GroceryState>(
      builder: (_, state) {
        if (widget.state.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }
        return Scaffold(
          backgroundColor: const Color(0xffF9F9F9),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: gapSymmetric(horizontal: 20, vertical: 16),
                    child: SearchBarWidget(controller: widget.controller),
                  ),

                  CategoryTabs(
                    categories: const [
                      "Requested Items",
                      "AI Generated List",
                      "Final List",
                    ],
                    selectedIndex: selectedIndex,
                    onTabSelected: (index) {
                      updateIndex(index);
                    },
                  ),
                  gap(height: 16),
                  _buildListWidget(state),
                ],
              ),
            ),
          ),
          floatingActionButton: selectedIndex == 2
              ? FloatingActionButton(
                  key: Key("final_list"),
                  heroTag: "final_list",
                  tooltip: "Add Custom Items",
                  backgroundColor: AppColors.primaryColor,
                  shape: const CircleBorder(),
                  onPressed: () => context.push(Routes.addCustomItem),
                  child: const Icon(Icons.add, color: Colors.black),
                )
              : null,
        );
      },
    );
  }

  Widget _buildListWidget(GroceryState state) {
    List<RequestedItemEntity> currentList = switch (selectedIndex) {
      0 => state.requestedItemsList ?? [],
      1 => state.aiGeneratedList ?? [],
      2 => state.finalListItemsList ?? [],

      int() => [],
    };
    return Padding(
      padding: gapSymmetric(horizontal: 16),
      child: currentList.isEmpty
          ? Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  gap(height: 142),
                  Image.asset(AppAssets.groceryEmpty, width: w(112)),
                  gap(height: 12),
                  Text(
                    "Your grocery list is empty",
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Color(0xffC3C3C3),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                if (selectedIndex == 2)
                  Padding(
                    padding: gapOnly(bottom: 14),
                    child: GenericButtonWidget(
                      isLoading: widget.state.isLoading,
                      onPressed: () {
                        if (currentList.isNotEmpty) {
                          widget.groceryBloc.add(
                            AddMylistToInventoryEvent(
                              kitchenId: widget.userCubit.state.activeKitchenId,
                            ),
                          );
                        }
                      },
                      text: "+ Add to Inventory",
                    ),
                  ),

                UpperTile(
                  verticalPadding: 8,
                  widget: Column(
                    children: List.generate(currentList.length, (index) {
                      final item = currentList[index];
                      return GroceryListItem(
                        grocery: item,
                        isChecked: _isChecked(item.itemId),
                        isFinalList: selectedIndex == 2,
                        onChanged: (val) => _toggle(item.itemId, state),
                        onDelete: () => _delete(context, item.itemId),
                        showDivider: index != currentList.length - 1,
                      );
                    }),
                  ),
                ),

                gap(height: 16),
                if (selectedIndex == 2)
                  FinalListFooter(
                    isFinalListTabTriggered: true,
                    groceryList: state.finalListItemsList ?? [],
                    onRemoveCallback: () {
                      deleteAll(context, state.finalListItemsList ?? []);
                    },
                    onAddToFinalListCallback: () {},
                  )
                else
                  FinalListFooter(
                    isFinalListTabTriggered: false,
                    groceryList: state.requestedItemsList ?? [],
                    onRemoveCallback: () {
                      deleteAll(context, state.requestedItemsList ?? []);
                    },
                    onAddToFinalListCallback: () {
                      if (requestedAndAiGeneratedSelectedList.isEmpty) {
                        AppToast.show(
                          "Please select at least one item",
                          ToastType.error,
                        );
                        return;
                      }
                      widget.groceryBloc.add(
                        UpdateBucketTypeEvent(
                          kitchenId: widget.userCubit.state.activeKitchenId,
                          itemIds: requestedAndAiGeneratedSelectedList,
                          bucketType: "mylist",
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }

  bool _isChecked(String itemId) {
    return requestedAndAiGeneratedSelectedList.contains(itemId);
  }

  void _toggle(String id, GroceryState state) {
    final list = selectedIndex == 2
        ? finalListSelectedItems
        : requestedAndAiGeneratedSelectedList;
    list.contains(id) ? list.remove(id) : list.add(id);
    setState(() {});
  }

  void _delete(BuildContext context, String id) {
    showDialogForItemDeletion(
      context,

      callback: () {
        if (selectedIndex != 2) {
          widget.groceryBloc.add(
            DeleteKitchenItemsEvent(
              kitchenId: widget.userCubit.state.activeKitchenId,
              itemIds: [id],
            ),
          );
        } else {
          widget.groceryBloc.add(
            UpdateBucketTypeEvent(
              kitchenId: widget.userCubit.state.activeKitchenId,
              itemIds: [id],
              bucketType: "requested",
            ),
          );
        }
      },
    );
  }

  void deleteAll(BuildContext context, List<RequestedItemEntity> currentList) {
    showDialogForItemDeletion(
      context,
      callback: () {
        final itemIds = currentList.map((item) => item.itemId).toList();

        if (selectedIndex != 2) {
          widget.groceryBloc.add(
            DeleteKitchenItemsEvent(
              kitchenId: widget.userCubit.state.activeKitchenId,
              itemIds: itemIds,
            ),
          );
        } else {
          widget.groceryBloc.add(
            UpdateBucketTypeEvent(
              kitchenId: widget.userCubit.state.activeKitchenId,
              itemIds: itemIds,
              bucketType: "requested",
            ),
          );
        }
      },
    );
  }
}
