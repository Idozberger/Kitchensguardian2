part of 'package:foodkitchen/features/consumptions/presentation/widgets/consumption_confirmation_card.dart';

extension _ConsumptionConfirmationCardLayout on ConsumptionConfirmationCard {
  Widget consumptionCardBody(BuildContext context) {
    return Column(
      spacing: h(4),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        consumptionBuildHeader(context),
        consumptionBuildQuantityDisplay(context),
        consumptionBuildDepletionPrediction(context),
        consumptionBuildInfoCards(),
        SizedBox(),
        consumptionBuildActionButtons(context),
      ],
    );
  }

  Widget consumptionBuildHeader(BuildContext context) {
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

  Widget consumptionBuildQuantityDisplay(BuildContext context) {
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

  Widget consumptionBuildDepletionPrediction(BuildContext context) {
    return UpperTile(
      borderColor: Colors.grey.shade100,
      color: Colors.grey.shade50,
      widget: Row(
        spacing: w(8),
        children: [consumptionBuildDepletionInfo(context)],
      ),
    );
  }

  Widget consumptionBuildDepletionInfo(BuildContext context) {
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

  Widget consumptionBuildInfoCards() {
    return Row(
      spacing: w(4),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _InfoCard(title: "Added", value: addedAt ?? "N/A"),
        _InfoCard(title: "Expires", value: expiresAt ?? "N/A"),
      ],
    );
  }

  Widget consumptionBuildActionButtons(BuildContext context) {
    return Row(
      spacing: w(4),
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

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        width: w(184),
        padding: gapAll(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
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
