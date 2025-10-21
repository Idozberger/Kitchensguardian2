import 'package:flutter/material.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/grocery/presentation/pages/grocery_parts/grocery_body.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/final_list_footer.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';

class GroceryFooter extends StatelessWidget {
  final GroceryCategory selectedCategory;
  final GroceryState state;
  final List<String> itemIds;
  final List<String> finalListItems;
  final GroceryBloc groceryBloc;
  final UserCubit userCubit;

  const GroceryFooter({
    super.key,
    required this.selectedCategory,
    required this.state,
    required this.itemIds,
    required this.finalListItems,
    required this.groceryBloc,
    required this.userCubit,
  });

  @override
  Widget build(BuildContext context) {
    return switch (selectedCategory) {
      GroceryCategory.finalList => FinalListFooter(
        shareString: state.finalListItemsList.toString(),
        totalItems: state.finalListItemsList?.length ?? 0,
        completedItems: finalListItems.length,
      ),
      _ => GenericButtonWidget(
        text: "+ Add To Final List",
        onPressed: () {
          if (itemIds.isEmpty) {
            return AppToast.show(
              "Please select at least one item before updating the bucket type.",
              ToastType.error,
            );
          }

          groceryBloc.add(
            UpdateBucketTypeEvent(
              kitchenId: userCubit.state.activeKitchenId,
              itemIds: itemIds,
              bucketType: "mylist",
            ),
          );
          finalListItems
            ..clear()
            ..addAll(itemIds);
        },
      ),
    };
  }
}
