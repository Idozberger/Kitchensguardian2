import 'package:flutter/material.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:share_plus/share_plus.dart';

class ShareButton extends StatelessWidget {
  final String shareString;
  const ShareButton({super.key, required this.shareString});

  @override
  Widget build(BuildContext context) {
    return GenericButtonWidget(
      onPressed: () async {
        await Share.share(
          "Grocery List\n$shareString",
          subject: 'My Grocery List',
        );
      },

      text: "Share List",
    );
  }
}
