import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_parts/grocery_body.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_parts/grocery_list_item.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/show_delete_dialog.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';

class GroceryListView extends StatefulWidget {
  final GroceryState state;
  final GroceryCategory selectedCategory;
  final TextEditingController searchController;
  final List<String> itemIds;
  final List<String> finalListItems;
  final UserCubit userCubit;
  final GroceryBloc groceryBloc;

  const GroceryListView({
    super.key,
    required this.state,
    required this.selectedCategory,
    required this.searchController,
    required this.itemIds,
    required this.finalListItems,
    required this.userCubit,
    required this.groceryBloc,
  });

  @override
  State<GroceryListView> createState() => _GroceryListViewState();
}

class _GroceryListViewState extends State<GroceryListView> {
  @override
  Widget build(BuildContext context) {
    if (widget.state.isLoading) {
      return Center(
        child: Padding(
          padding: EdgeInsets.only(top: 200),
          child: CircularProgressIndicator(color: AppColors.primaryColor),
        ),
      );
    }

    final currentList = switch (widget.selectedCategory) {
      GroceryCategory.requested => widget.state.requestedItemsList,
      GroceryCategory.aiGenerated => widget.state.aiGeneratedList,
      GroceryCategory.finalList => widget.state.finalListItemsList,
    };

    if (currentList == null || currentList.isEmpty) {
      return Padding(
        padding: gapOnly(top: 120),
        child: EmptyStateWidget(
          context,
          imagePath: AppAssets.groceryEmpty,
          title: 'No items found',
        ),
      );
    }

    final query = widget.searchController.text.toLowerCase();
    final filtered = currentList
        .where((e) => e.name.toLowerCase().contains(query))
        .toList();

    return Column(
      children: [
        if (widget.selectedCategory == GroceryCategory.finalList)
          Padding(
            padding: gapOnly(bottom: 14),
            child: GenericButtonWidget(
              isLoading: widget.state.isLoading,
              onPressed: () {
                if (widget.finalListItems.isNotEmpty) {
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
            children: List.generate(filtered.length, (index) {
              final item = filtered[index];
              return GroceryListItem(
                grocery: item,
                isChecked: _isChecked(item.itemId),
                isFinalList: false,
                onChanged: (val) => _toggle(item.itemId),
                onDelete: () => _delete(context, item.itemId),
                showDivider: index != filtered.length - 1,
              );
            }),
          ),
        ),
      ],
    );
  }

  bool _isChecked(String id) {
    return widget.selectedCategory == GroceryCategory.finalList
        ? widget.finalListItems.contains(id)
        : widget.itemIds.contains(id);
  }

  void _toggle(String id) {
    final list = widget.selectedCategory == GroceryCategory.finalList
        ? widget.finalListItems
        : widget.itemIds;
    list.contains(id) ? list.remove(id) : list.add(id);
    setState(() {});
  }

  void _delete(BuildContext context, String id) {
    final selectedList = widget.selectedCategory == GroceryCategory.finalList
        ? widget.finalListItems
        : widget.itemIds;
    if (!selectedList.contains(id)) {
      return AppToast.show("Select item to delete", ToastType.error);
    }

    showDialogForItemDeletion(
      context,
      id,
      callback: () {
        if (widget.selectedCategory != GroceryCategory.finalList) {
          widget.groceryBloc.add(
            DeleteKitchenItemsEvent(
              kitchenId: widget.userCubit.state.activeKitchenId,
              itemIds: selectedList,
            ),
          );
        } else {
          widget.groceryBloc.add(
            UpdateBucketTypeEvent(
              kitchenId: widget.userCubit.state.activeKitchenId,
              itemIds: selectedList,
              bucketType: "requested",
            ),
          );
        }
      },
    );
  }
}
