import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart' show AppAssets;
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:go_router/go_router.dart';

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
    return PopupMenuButton<int>(
      color: Colors.white,
      offset: Offset(w(-20), 40),
      padding: gapZero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(h(10)),
        side: const BorderSide(color: Color(0xffD4D2D2)),
      ),
      onSelected: (value) {
        switch (value) {
          case 0:
            debugPrint("Edit Day Plan clicked");
            context.push(Routes.editMeal);
            break;
          case 1:
            debugPrint("Share Day Plan clicked");
            AppToast.show("Share Day Plan", ToastType.success);

            break;
          case 2:
            deletePlan();

            break;
        }
      },
      itemBuilder: (context) => [
        _menuItem(
          context,
          value: 0,
          icon: AppAssets.editSvg,
          label: "Edit Day Plan",
          textColor: Colors.black,
        ),
        _menuItem(
          context,
          value: 1,
          icon: AppAssets.shareSvg,
          label: "Share Day Plan",
          textColor: Colors.black,
        ),
        _menuItem(
          context,
          value: 2,
          icon: AppAssets.deleteSvg,
          label: "Clear Day Plan",
          textColor: Colors.red,
        ),
      ],
      icon: SvgPicture.asset(AppAssets.popupMenuSvg),
    );
  }

  PopupMenuItem<int> _menuItem(
    BuildContext context, {
    required int value,
    required String icon,
    required String label,
    required Color textColor,
  }) {
    return PopupMenuItem(
      value: value,
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
    );
  }
}
