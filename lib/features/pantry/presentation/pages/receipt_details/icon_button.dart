import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class IconButtonWidget extends StatelessWidget {
  final String iconPath;
  final VoidCallback onTap;

  const IconButtonWidget({
    required this.iconPath,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD4D2D2)),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(iconPath),
      ),
    );
  }
}
