import 'package:flutter/material.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

class ConfirmButton extends StatelessWidget {
  final bool canConfirm;
  final VoidCallback onConfirm;

  const ConfirmButton({
    super.key,
    required this.canConfirm,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GenericButtonWidget(
        onPressed: onConfirm,
        text: 'Analyse My Kitchen',
      ),
    );
  }
}
