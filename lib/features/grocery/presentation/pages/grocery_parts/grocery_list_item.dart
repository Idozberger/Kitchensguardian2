import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/widgets/generic_container_checktile_widget.dart';

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
