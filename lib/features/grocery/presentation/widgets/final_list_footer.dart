import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/grocery/domain/entities/requested_item.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/remove_all_button.dart';
import 'package:foodkitchen/features/grocery/presentation/widgets/share_button.dart';

class FinalListFooter extends StatelessWidget {
  final List<RequestedItemEntity>? groceryList;
  final VoidCallback onRemoveCallback;
  final VoidCallback onAddToFinalListCallback;

  final bool isFinalListTabTriggered;

  const FinalListFooter({
    super.key,
    required this.groceryList,
    required this.onRemoveCallback,
    required this.onAddToFinalListCallback,

    this.isFinalListTabTriggered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: RemoveAllButton(callback: onRemoveCallback)),
        SizedBox(width: w(12)),
        Expanded(
          child: isFinalListTabTriggered
              ? ShareButton(groceryList: groceryList ?? [])
              : GenericButtonWidget(
                  text: "+ Add To Final List",
                  onPressed: onAddToFinalListCallback,
                ),
        ),
      ],
    );
  }
}
