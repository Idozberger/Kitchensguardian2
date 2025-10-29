import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';

class GenericDialog extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color backgroundColor;

  const GenericDialog({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
      child: Dialog(
        backgroundColor: Colors.white,
        insetPadding: gapSymmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: gapSymmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: backgroundColor.withOpacity(0.9),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
