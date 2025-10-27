import 'package:flutter/material.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/grocery/domain/entities/requested_item.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  final List<RequestedItemEntity> groceryList;

  const ShareButton({super.key, required this.groceryList});

  @override
  Widget build(BuildContext context) {
    return GenericButtonWidget(
      text: "Share List",
      onPressed: () async {
        if (groceryList.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("No items to share")));
          return;
        }

        final String shareString = groceryList
            .asMap()
            .entries
            .map((entry) {
              final index = entry.key + 1;
              final item = entry.value;
              final name = item.name ?? 'Unnamed';
              final quantity = item.quantity?.toString() ?? '-';
              final unit = item.unit ?? '';
              return "$index️⃣  $name\n     Quantity: $quantity $unit";
            })
            .join("\n\n");

        final formattedList =
            """
🛒 *My Grocery List*  
━━━━━━━━━━━━━━━  
$shareString  
━━━━━━━━━━━━━━━  
🗓️ Shared via MyGroceryApp
""";

        await Share.share(formattedList, subject: 'My Grocery List');
      },
    );
  }
}
