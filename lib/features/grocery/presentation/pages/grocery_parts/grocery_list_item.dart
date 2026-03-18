import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/widgets/generic_container_checktile_widget.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/dialogs/show_edit_ingredient_dialog.dart';

class GroceryListItem extends StatelessWidget {
  final RequestedItemEntity grocery;
  final bool isChecked;
  final bool isFinalList;
  final void Function(Object?) onChanged;
  final VoidCallback onDelete;
  final bool showDivider;

  const GroceryListItem({
    super.key,
    required this.grocery,
    required this.isChecked,
    required this.isFinalList,
    required this.onChanged,
    required this.onDelete,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GenericCircleCheckboxTile(
          editCallback: () => showEditItemDialog(
            context,
            kitchenId: context.read<UserCubit>().state.activeKitchenId,
            itemId: grocery.itemId,
            initialName: grocery.name,
            initialQuantity: grocery.quantity,
            initialUnit: grocery.unit,
            groceryBloc: context.read<GroceryBloc>(),
          ),
          unit: grocery.unit,
          quantity: grocery.quantity,
          title: grocery.name,
          isChecked: isChecked,
          isFinalList: isFinalList,
          activeColor: AppColors.primaryColor,
          contentPadding: gapAll(6),
          onChanged: onChanged,
          deleteCallback: onDelete,
        ),
        if (showDivider) const Divider(color: Color(0xffF4F4F4)),
      ],
    );
  }
}
