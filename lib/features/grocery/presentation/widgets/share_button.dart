import 'package:flutter/material.dart';
import 'package:foodkitchen/core/common/domain/entities/requested_item.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  final List<RequestedItemEntity> groceryList;

  const ShareButton({super.key, required this.groceryList});

  @override
  Widget build(BuildContext context) {
    return GenericButtonWidget(
      text: "Share List",
      onPressed: () => _handleShare(context),
    );
  }

  Future<void> _handleShare(BuildContext context) async {
    if (groceryList.isEmpty) {
      _showEmptyListSnackBar(context);
      return;
    }

    final formattedList = _buildFormattedList();
    await SharePlus.instance.share(
      ShareParams(text: formattedList, subject: 'My Grocery List'),
    );
  }

  void _showEmptyListSnackBar(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("No items to share")));
  }

  String _buildFormattedList() {
    final itemsList = _buildItemsList();
    return _formatListWithBorders(itemsList);
  }

  String _buildItemsList() {
    return groceryList
        .asMap()
        .entries
        .map((entry) => _formatListItem(entry.key + 1, entry.value))
        .join("\n\n");
  }

  String _formatListItem(int index, RequestedItemEntity item) {
    return "$index️⃣  ${item.name}\n     Quantity: ${item.quantity} ${item.unit}";
  }

  String _formatListWithBorders(String itemsList) {
    return """
🛒 *My Grocery List*  
━━━━━━━━━━━━━━━  
$itemsList  
━━━━━━━━━━━━━━━  
🗓️ Shared via MyGroceryApp
""";
  }
}
