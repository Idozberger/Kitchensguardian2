import 'package:flutter/material.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

Future<bool?> showRecipesRequestUncheckStepDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => GenericDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Uncheck Step",
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: t(14),
            ),
          ),
          gap(height: 12),
          Text(
            "Are you sure you want to mark this step as incomplete?",
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: t(14),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Yes"),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
