import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/dialogs/delete_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';

class PantryItemCard extends StatefulWidget {
  final String title;
  final String quantity;
  final String unit;
  final String pantry;
  final VoidCallback onListCheckedCallback;
  final String expiry;

  const PantryItemCard({
    super.key,
    required this.title,
    required this.quantity,
    required this.unit,
    required this.pantry,
    required this.expiry,
    required this.onListCheckedCallback,
  });

  @override
  State<PantryItemCard> createState() => _PantryItemCardState();
}

class _PantryItemCardState extends State<PantryItemCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isExpanded = !_isExpanded);
      },
      child: Container(
        margin: gapSymmetric(vertical: 0),
        padding: gapAll(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(h(10)),
          border: Border.all(color: const Color(0xffD4D2D2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Top Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: _isExpanded ? null : w(54),
                      child: Text(
                        widget.title,
                        maxLines: _isExpanded ? null : 1,
                        overflow: _isExpanded ? null : TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    if (!_isExpanded) ...[
                      SizedBox(width: w(12)),
                      _buildInlineInfo(widget.quantity),
                      _dot(),
                      _buildInlineInfo(widget.unit),
                      _dot(),
                      _buildInlineInfo(widget.pantry),
                    ],
                  ],
                ),
                AnimatedRotation(
                  turns: _isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: SvgPicture.asset(AppAssets.downArrow),
                ),
              ],
            ),

            /// Expanded Details
            if (_isExpanded) ...[
              SizedBox(height: h(15)),
              Row(
                children: [
                  _buildInlineInfo(widget.quantity, isExpanded: _isExpanded),
                  _dot(),
                  _buildInlineInfo(widget.unit, isExpanded: _isExpanded),
                  _dot(),
                  _buildInlineInfo(widget.pantry, isExpanded: _isExpanded),
                ],
              ),
              SizedBox(height: h(10)),
              Text(
                widget.expiry,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: t(14),
                  color: const Color(0xff787878),
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: h(15)),

              /// Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // _circleButton(AppAssets.editSvg, () {}),
                  _circleButton(AppAssets.cartSvg, () {}),
                  _circleButton(
                    AppAssets.listCheckedSvg,
                    () => widget.onListCheckedCallback(),
                  ),
                  _circleButton(AppAssets.deleteSvg, () {
                    _showDeleteDialog(context);
                  }),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInlineInfo(String text, {bool isExpanded = false}) {
    if (isExpanded) {
      return Text(
        text,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontSize: t(14),
          color: const Color(0xff787878),
          fontWeight: FontWeight.w400,
        ),
      );
    } else {
      return SizedBox(
        width: w(50),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: t(14),
            color: const Color(0xff787878),
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }
  }

  Widget _dot() => Padding(
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

  Widget _circleButton(String asset, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.only(left: w(8)),
      child: CircularIconButton(iconAsset: asset, onTap: onTap),
    );
  }

  Future<dynamic> _showDeleteDialog(BuildContext context) {
    return showCustomGenericDialog(
      context: context,
      title: "Remove Item",
      subtitle: "Are you sure you want to delete this item?",
      primaryButtonText: "Yes",
      secondaryButtonText: "Cancel",
      onPrimaryPressed: () {
        AppToast.show("Item removed", ToastType.success);
        Navigator.pop(context);
      },
      onSecondaryPressed: () {
        Navigator.pop(context);
      },
    );
  }
}
