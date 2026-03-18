import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final bool isLoading;
  final bool filled;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.accent,
    required this.onTap,
    this.isLoading = false,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GenericButtonWidget(
      color: Color(0xffFEF2DA),
      isOutlined: true,
      onPressed: isLoading ? () {} : onTap,
      text: label,
      isLoading: isLoading,
      textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontSize: t(12),
        color: Colors.black,
      ),
    );
  }
}
