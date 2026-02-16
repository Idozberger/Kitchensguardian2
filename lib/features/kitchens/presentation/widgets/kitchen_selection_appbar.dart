import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';

import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:go_router/go_router.dart';

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
      actions: [
        IconButton(
          onPressed: () => context.push(Routes.logout),
          icon: SvgPicture.asset(AppAssets.signoutSvg, color: Colors.redAccent),
        ),
        SizedBox(width: w(8)),
      ],
    );
  }
}
