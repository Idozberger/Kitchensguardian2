import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/history/domain/entities/scan_item_entity.dart';

class HistoryItemDetails extends StatelessWidget {
  final List<ScanItemEntity> details;

  const HistoryItemDetails({super.key, required this.details});

  @override
  Widget build(BuildContext context) {
    if (details.isEmpty) {
      return Padding(
        padding: gapOnly(top: 12),
        child: Text(
          "No items found",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: t(14),
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Padding(
      padding: gapOnly(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: details.map((item) => HistoryDetailItem(item: item)).toList(),
      ),
    );
  }
}

class HistoryDetailItem extends StatelessWidget {
  final ScanItemEntity item;

  const HistoryDetailItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: gapOnly(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: w(14)),

          if (item.thumbnail.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                item.thumbnail,
                width: w(44),
                height: h(44),

                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: w(44),
                    height: h(44),
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                      size: 28,
                    ),
                  );
                },
              ),
            ),

          if (item.thumbnail.isNotEmpty) SizedBox(width: w(14)),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: t(14),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: h(4)),
                Text(
                  "${item.amount} ${item.unit}",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: const Color(0xff787878),
                    fontSize: t(14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
