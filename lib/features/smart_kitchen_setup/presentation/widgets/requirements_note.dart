import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class RequirementNote extends StatelessWidget {
  final bool canConfirm;

  const RequirementNote({super.key, required this.canConfirm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapOnly(left: 20, right: 20, top: 14, bottom: 8),
      child: Row(
        children: [
          Icon(
            canConfirm
                ? Icons.check_circle_outline_rounded
                : Icons.info_outline_rounded,
            color: canConfirm
                ? const Color(0xFF4AE68A)
                : const Color(0xFF555A70),
            size: t(16),
          ),
          SizedBox(width: w(8)),
          SizedBox(
            width: w(300),
            child: Text(
              canConfirm
                  ? 'Ready to continue! You can add more sections if you like.'
                  : 'Scan at least 2 sections to continue.',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: canConfirm
                    ? const Color(0xFF4AE68A)
                    : const Color(0xFF555A70),
                fontSize: t(13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
