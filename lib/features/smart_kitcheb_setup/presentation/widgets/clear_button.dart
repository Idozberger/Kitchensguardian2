import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class ClearButton extends StatelessWidget {
  final VoidCallback onTap;
  const ClearButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: w(44),
        height: h(44),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xffF6A500), width: 1.5),
          shape: BoxShape.circle,
          color: Color(0xffFEF2DA),
        ),
        child: Center(
          child: SvgPicture.asset(
            AppAssets.deleteSvg,
            width: w(18),
            height: h(18),
            fit: BoxFit.contain,
            colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
