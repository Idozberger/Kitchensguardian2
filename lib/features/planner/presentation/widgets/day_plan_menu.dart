import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class DayPlanMenu extends StatelessWidget {
  final VoidCallback deletePlan;
  final VoidCallback editPlan;

  const DayPlanMenu({
    super.key,
    required this.deletePlan,
    required this.editPlan,
  });

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeRight: true,
      child: PopupMenuButton<int>(
        color: Colors.white,
        offset: Offset(w(-20), h(20)),
        padding: gapZero,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(h(8)),
          side: const BorderSide(color: Color(0xffD4D2D2)),
        ),
        itemBuilder: (context) => [
          _customMenuItem(
            context,
            value: 0,
            icon: AppAssets.editSvg,
            label: "Edit Day Plan",
            textColor: Colors.black,
            onTap: editPlan,
          ),
          _customMenuItem(
            context,
            value: 2,
            icon: AppAssets.deleteSvg,
            label: "Clear Day Plan",
            textColor: Colors.red,
            onTap: deletePlan,
          ),
        ],
        borderRadius: BorderRadius.circular(h(55)),
        child: Padding(
          padding: gapOnly(right: 14, left: 14, bottom: 8, top: 8),
          child: SvgPicture.asset(AppAssets.popupMenuSvg),
        ),
      ),
    );
  }

  PopupMenuEntry<int> _customMenuItem(
    BuildContext context, {
    required int value,
    required String icon,
    required String label,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return PopupMenuItem<int>(
      value: value,

      padding: EdgeInsets.zero,
      enabled: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: w(12), vertical: h(10)),
          child: Row(
            children: [
              SvgPicture.asset(icon),
              SizedBox(width: w(10)),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
