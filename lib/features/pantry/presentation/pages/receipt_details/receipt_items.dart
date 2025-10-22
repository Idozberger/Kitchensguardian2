import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/pantry/domain/entities/scan_receipt.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/receipt_details/icon_button.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/list_tile.dart';

class ReceiptItemsListWidget extends StatelessWidget {
  final ScanReceipt scanReceipt;
  final void Function(int) onIncrement;
  final void Function(int) onDecrement;

  const ReceiptItemsListWidget({
    required this.scanReceipt,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (scanReceipt.items.isEmpty) {
      return const Center(child: Text("No items found"));
    }

    return ListView.separated(
      itemCount: scanReceipt.items.length,
      separatorBuilder: (_, __) =>
          const Divider(color: Color(0xFFF4F4F4), height: 1),
      itemBuilder: (context, index) {
        final item = scanReceipt.items[index];
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(child: ListItemWidget(text: item.name)),
            Row(
              children: [
                IconButtonWidget(
                  iconPath: AppAssets.decreamentSvg,
                  onTap: () => onDecrement(index),
                ),
                SizedBox(width: w(8)),
                Text(
                  item.amount,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(fontSize: t(10)),
                ),
                SizedBox(width: w(8)),
                IconButtonWidget(
                  iconPath: AppAssets.increamentSvg,
                  onTap: () => onIncrement(index),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
