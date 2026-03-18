import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/data/models/kitchen_section_model.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/widgets/action_buttons.dart';
import 'package:foodkitchen/features/smart_kitchen_setup/presentation/widgets/clear_button.dart';

class SectionCardActions extends StatelessWidget {
  final KitchenSection section;
  final bool isDone;
  final bool isScanning;
  final VoidCallback onScan;
  final VoidCallback onClear;

  const SectionCardActions({
    super.key,
    required this.section,
    required this.isDone,
    required this.isScanning,
    required this.onScan,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapAll(16),
      child: Row(
        children: [
          if (isDone) ...[ClearButton(onTap: onClear), SizedBox(width: w(8))],
          Expanded(
            child: ActionButton(
              label: isDone ? 'Re-scan' : 'Scan Photo',
              icon: isDone ? Icons.refresh_rounded : Icons.add_a_photo_outlined,
              accent: section.accent,
              isLoading: isScanning,
              onTap: onScan,
              filled: !isDone,
            ),
          ),
        ],
      ),
    );
  }
}
