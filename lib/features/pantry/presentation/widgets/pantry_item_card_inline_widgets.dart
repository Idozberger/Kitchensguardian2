import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';

class PantryItemCardLockOverlay extends StatelessWidget {
  const PantryItemCardLockOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const SizedBox(height: 10),
        Positioned(
          top: -h(34),
          left: w(58),
          child: Container(
            padding: gapAll(12),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              borderRadius: BorderRadius.circular(t(100)),
            ),
            child: Row(
              spacing: w(12),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(AppAssets.crownImage, height: h(24)),
                Text(
                  "Upgrade to see more",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontSize: t(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget pantryItemCardInlineInfo(
  BuildContext context,
  String text, {
  bool isExpanded = false,
}) {
  return Text(
    text,
    overflow: TextOverflow.ellipsis,
    maxLines: 1,
    textAlign: isExpanded ? TextAlign.start : TextAlign.left,
    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
      fontSize: t(14),
      color: const Color(0xff787878),
      fontWeight: FontWeight.w400,
    ),
  );
}

Widget pantryItemCardDot(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: w(8)),
    child: Container(
      width: w(4),
      height: h(4),
      decoration: const BoxDecoration(
        color: Color(0xff787878),
        shape: BoxShape.circle,
      ),
    ),
  );
}

Widget pantryItemCardCircleButton(String asset, VoidCallback onTap) {
  return Padding(
    padding: EdgeInsets.only(left: w(8)),
    child: CircularIconButton(iconAsset: asset, onTap: onTap),
  );
}
