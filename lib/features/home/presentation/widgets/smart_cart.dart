import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/features/home/presentation/widgets/rounded_text_container.dart';

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
      widget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: h(8),
        children: [
          _buildHeader(context),
          if (isGenerated)
            _buildPreview(context)
          else
            _buildEmptyState(context),

          GenericButtonWidget(
            text: "Generate Ai Grocery List",
            onPressed: onGenerate,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
  }

  Widget _buildPreview(BuildContext context) {
    return previewItems.isEmpty
        ? _buildEmptyState(context)
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: h(8),
            children: [
              _buildPreviewLabel(context),
              _buildItemsList(),
              if (infoText != null) _buildInfoButton(),
            ],
          );
  }

  Widget _buildPreviewLabel(BuildContext context) {
    return Text(
      "Preview items:",
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontSize: t(12),
        color: const Color(0xFF787878),
      ),
    );
  }

  Widget _buildItemsList() {
    return Wrap(
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
    );
  }

  Widget _buildInfoButton() {
    return IntrinsicWidth(
      child: InkWell(
        onTap: onGenerate,
        child: RoundedTextContainer(text: infoText!),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Text(
      "No items available in Pantry",
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontSize: t(12),
        color: const Color(0xFF787878),
      ),
    );
  }
}
