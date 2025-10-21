import 'package:flutter/material.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

class AddToFinalListButton extends StatelessWidget {
  final bool hasItems;
  final List<String> itemIds;
  final VoidCallback onPressed;

  const AddToFinalListButton({
    super.key,
    required this.hasItems,
    required this.itemIds,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasItems) return const SizedBox.shrink();
    return GenericButtonWidget(text: "Add to Final List", onPressed: onPressed);
  }
}
