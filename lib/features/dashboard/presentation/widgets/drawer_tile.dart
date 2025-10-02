import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class DrawerListTile extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback onTap;

  const DrawerListTile({
    super.key,
    required this.title,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: SvgPicture.asset(iconPath),
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
