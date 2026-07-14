import 'package:flutter/material.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';

class KitchenAnalysisEmptyItemsPlaceholder extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const KitchenAnalysisEmptyItemsPlaceholder({
    super.key,
    this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final bool isError = errorMessage != null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.inventory_2_outlined,
            size: 48,
            color: isError ? Colors.redAccent : Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            isError ? 'Scan failed' : 'No items found',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isError ? errorMessage! : 'Scanned items will appear here',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          if (isError && onRetry != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: 160,
              child: GenericButtonWidget(
                onPressed: onRetry!,
                text: 'Try Again',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
