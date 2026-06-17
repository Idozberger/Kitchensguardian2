// ignore_for_file: unused_element_parameter
// Callback parameters kept for API symmetry with sibling widgets.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_bloc.dart';
import 'package:foodkitchen/features/consumptions/presentation/bloc/consumption_state.dart';

import 'package:go_router/go_router.dart';

part 'consumption_confirmation_card_part.dart';

// False positive: StatelessWidget is immutable; analyzer mis-infers from generated/partials.
// ignore: must_be_immutable
class ConsumptionConfirmationCard extends StatelessWidget {
  final String itemName;
  final String confirmationId;
  final double quantity;
  final String unit;
  final String status;
  final String? predictedDepletionDate;
  final String? addedAt;
  final String? expiresAt;
  final String? confirmedAt;
  final VoidCallback onConfirm;
  final VoidCallback onDeny;
  final bool isLoading;

  ConsumptionConfirmationCard({
    super.key,
    required this.itemName,
    required this.confirmationId,
    required this.quantity,
    required this.unit,
    required this.status,
    required this.predictedDepletionDate,
    required this.addedAt,
    required this.expiresAt,
    this.confirmedAt,
    required this.onConfirm,
    required this.onDeny,
    this.isLoading = false,
  });
  Map<String, Map<String, Color>> statusColors = {
    "pending": {
      "background": Colors.orange.shade100,
      "text": Colors.orange.shade800,
    },
    "confirmed": {
      "background": Colors.green.shade100,
      "text": Colors.green.shade800,
    },
    "denied": {"background": Colors.red.shade100, "text": Colors.red.shade800},
    "expired": {
      "background": Colors.grey.shade300,
      "text": Colors.grey.shade700,
    },
  };

  @override
  Widget build(BuildContext context) {
    return UpperTile(widget: consumptionCardBody(context));
  }

  Future<void> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocBuilder<ConsumptionBloc, ConsumptionState>(
        builder: (context, state) {
          return GenericDialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Row(
                  spacing: w(12),
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      child: GenericButtonWidget(
                        isOutlined: true,
                        color: Colors.white,

                        onPressed: () {
                          context.pop();
                        },
                        text: "Cancel",
                      ),
                    ),
                    Flexible(
                      child: GenericButtonWidget(
                        isLoading: state.respondingOnConsumptionLoader,
                        color: AppColors.primaryColor,
                        onPressed: () {
                          onConfirm();
                        },
                        text: confirmText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
