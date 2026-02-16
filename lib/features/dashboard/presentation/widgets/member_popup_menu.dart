import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';

class MemberPopupMenu extends StatelessWidget {
  final VoidCallback onMakeCoHost;
  final VoidCallback onKick;
  final VoidCallback onDemoteCoHost;
  const MemberPopupMenu({
    super.key,
    required this.onMakeCoHost,
    required this.onKick,
    required this.onDemoteCoHost,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      offset: const Offset(0, 40),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xffD4D2D2)),
      ),
      onSelected: (value) {
        if (value == 0) onMakeCoHost();
        if (value == 1) onDemoteCoHost();
        if (value == 2) onKick();
      },
      itemBuilder: (context) => [
        _menuItem(
          context,
          value: 0,
          icon: AppAssets.tickSvg,
          label: "Make Co-Host",
        ),
        _menuItem(
          context,
          value: 1,
          icon: AppAssets.demoteCohost,
          label: "Demote Cohost",
        ),
        _menuItem(
          context,
          value: 2,
          icon: AppAssets.kickMemberSvg,
          label: "Kick",
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
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            height: label == "Demote Cohost" ? 18 : 12,
            color: Color(0xff787878),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
