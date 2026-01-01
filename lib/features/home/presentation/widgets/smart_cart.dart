// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/widgets/rounded_text_container.dart';
import 'package:go_router/go_router.dart';

class SmartCartTile extends StatelessWidget {
  final bool isGenerated;
  final List<String> previewItems;
  final VoidCallback onGenerate;
  final String? infoText;

  const SmartCartTile({
    super.key,
    required this.isGenerated,
    required this.previewItems,
    required this.onGenerate,
    this.infoText,
  });

  @override
  Widget build(BuildContext context) {
    return UpperTile(
      callback: onGenerate,
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(context),
          gap(height: 8),

          Visibility(visible: isGenerated, child: _preview(context)),
          Visibility(visible: isGenerated == false, child: _noItems(context)),
          gap(height: 12),
          GenericButtonWidget(text: "See More", onPressed: onGenerate),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("Smart Cart", style: Theme.of(context).textTheme.headlineLarge),
      SvgPicture.asset(
        AppAssets.cartSvg,
        color: AppColors.primaryColor,
        width: w(24),
        height: h(24),
      ),
    ],
  );

  Widget _preview(BuildContext context) => previewItems.isEmpty
      ? _noItems(context)
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Preview items:",
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: t(12),
                color: const Color(0xff787878),
              ),
            ),
            gap(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final item in previewItems)
                  IntrinsicWidth(
                    child: Padding(
                      padding: gapOnly(right: 6),
                      child: RoundedTextContainer(
                        text: item,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            gap(height: 12),
            if (infoText != null)
              IntrinsicWidth(
                child: InkWell(
                  onTap: () => context.push(Routes.smartCart),
                  child: RoundedTextContainer(text: infoText!),
                ),
              ),
          ],
        );

  Widget _noItems(BuildContext context) => Text(
    "No items available in Pantry",
    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontSize: t(12),
      color: const Color(0xff787878),
    ),
  );
}
