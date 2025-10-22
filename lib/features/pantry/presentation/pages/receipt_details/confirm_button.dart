import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

class ConfirmButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const ConfirmButtonWidget({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapAll(20),
      child: SafeArea(
        child: GenericButtonWidget(onPressed: onPressed, text: "Confirm"),
      ),
    );
  }
}
