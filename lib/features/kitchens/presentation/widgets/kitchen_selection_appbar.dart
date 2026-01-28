import 'package:flutter/material.dart';

import 'package:foodkitchen/core/global/functions/resize.dart';

class KitchenSelectionAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const KitchenSelectionAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: w(55),
      centerTitle: false,

      title: Text(
        "Kitchen’s Guardian",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
