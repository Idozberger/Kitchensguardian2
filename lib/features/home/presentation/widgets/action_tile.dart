import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

class ActionTile extends StatelessWidget {
  final String title;
  final String buttonText;
  final String svgPath;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.title,
    required this.buttonText,
    required this.svgPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          gap(height: 15),
          SizedBox(
            height: h(40),
            child: ElevatedButton.icon(
              onPressed: onTap,
              // ignore: deprecated_member_use
              icon: SvgPicture.asset(svgPath, color: Colors.black),
              label: Text(
                buttonText,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  fontSize: t(12),
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
