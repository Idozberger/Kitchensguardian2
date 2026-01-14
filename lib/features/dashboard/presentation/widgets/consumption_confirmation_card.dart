import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:foodkitchen/features/dashboard/presentation/bloc/dashboard_state.dart'
    show DashboardLoaded, DashboardLoading, DashboardState;
import 'package:go_router/go_router.dart';

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
    return UpperTile(
      widget: Column(
        spacing: h(12),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildQuantityDisplay(context),
          _buildDepletionPrediction(context),
          _buildInfoCards(),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final bgColor =
        statusColors[status.toLowerCase()]?["background"] ??
        Colors.grey.shade200;
    final txtColor =
        statusColors[status.toLowerCase()]?["text"] ?? Colors.black;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          itemName.isNotEmpty
              ? itemName[0].toUpperCase() + itemName.substring(1)
              : itemName,
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        _StatusChip(
          backgroundColor: bgColor,
          text: status,
          icon: AppAssets.addSvg,
          textColor: txtColor,
        ),
      ],
    );
  }

  Widget _buildQuantityDisplay(BuildContext context) {
    return Row(
      spacing: w(8),
      children: [
        Text(
          "$quantity $unit",
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDepletionPrediction(BuildContext context) {
    return UpperTile(
      borderColor: Colors.grey.shade100,
      color: Colors.grey.shade50,
      widget: Row(spacing: w(8), children: [_buildDepletionInfo(context)]),
    );
  }

  Widget _buildDepletionInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: h(6),
      children: [
        Text(
          "PREDICTED DEPLETION",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.black54,
            letterSpacing: -0.16,
            fontSize: t(12),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          predictedDepletionDate ?? "N/A",
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.black,
            letterSpacing: -0.16,
            fontSize: t(16),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards() {
    return Row(
      spacing: w(12),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InfoCard(title: "Added", value: addedAt ?? "N/A"),
        InfoCard(title: "Expires", value: expiresAt ?? "N/A"),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      spacing: w(12),
      children: [
        _ActionButton(
          text: "Confirm",
          callback: () => showConfirmationDialog(
            context: context,
            title: "Are you sure you want to confirm?",
            confirmText: "Confirm",
            confirmColor: Colors.green,
            onConfirm: onConfirm,
          ),
          buttonBgColor: Colors.green,
          isLoading: isLoading,
        ),
        _ActionButton(
          text: "Deny",
          callback: () => showConfirmationDialog(
            context: context,
            title: "Are you sure you want to deny?",
            confirmText: "Deny",
            confirmColor: Colors.red,
            onConfirm: onDeny,
          ),
          buttonBgColor: Colors.red,
          isLoading: isLoading,
        ),
      ],
    );
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
      builder: (_) => BlocBuilder<DashboardBloc, DashboardState>(
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
                        isLoading: state is DashboardLoading,
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

class _ActionButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final Color buttonBgColor;
  final VoidCallback callback;

  const _ActionButton({
    required this.text,
    required this.buttonBgColor,
    required this.callback,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SizedBox(
        height: h(38),
        child: GenericButtonWidget(
          color: buttonBgColor,
          borderRadius: BorderRadius.circular(12),
          onPressed: callback,
          text: text,
          isLoading: isLoading,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String icon;
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const _StatusChip({
    required this.icon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final capitalizedText = text.isNotEmpty
        ? text[0].toUpperCase() + text.substring(1)
        : text;

    return Container(
      padding: gapSymmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t(54)),
        color: backgroundColor,
      ),
      child: Row(
        spacing: w(4),
        children: [
          Text(
            capitalizedText,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? backgroundColor;

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        width: w(184),
        padding: gapAll(12),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.grey.shade100,
          borderRadius: BorderRadius.circular(t(12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: h(4)),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
