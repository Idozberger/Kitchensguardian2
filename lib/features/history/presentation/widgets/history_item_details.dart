import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/list_tile.dart';

class HistoryItemDetails extends StatelessWidget {
  final List<String> details;

  const HistoryItemDetails({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapOnly(top: 12),
      child: details.isEmpty
          ? Text(
              "No items found",
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontSize: t(10)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details
                  .map(
                    (e) => Padding(
                      padding: gapOnly(bottom: 6),
                      child: ListItemWidget(text: e),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
