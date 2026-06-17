import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class DrawerListTile extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;
  final Color? color;

  const DrawerListTile({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: gapZero,
      visualDensity: VisualDensity(vertical: -1),
      onTap: onTap,
      leading: SvgPicture.asset(
        iconPath,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineLarge!.copyWith(
          fontSize: t(15),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
