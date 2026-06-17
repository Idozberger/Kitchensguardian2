import 'package:flutter/material.dart';

class KitchenAnalysisEmptyItemsPlaceholder extends StatelessWidget {
  const KitchenAnalysisEmptyItemsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Scanned items will appear here',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
