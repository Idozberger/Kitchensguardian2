import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/features/history/presentation/widgets/history_item_details.dart';

class HistoryListTile extends StatefulWidget {
  final String title;
  final String date;
  final List<String> details;

  const HistoryListTile({
    super.key,
    required this.title,
    required this.date,
    required this.details,
  });

  @override
  State<HistoryListTile> createState() => _HistoryListTileState();
}

class _HistoryListTileState extends State<HistoryListTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        padding: gapAll(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(h(10)),
          border: Border.all(color: const Color(0xffD4D2D2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            if (_isExpanded) HistoryItemDetails(details: widget.details),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.headlineLarge?.copyWith(fontSize: t(14)),
            ),
            SizedBox(width: w(16)),
            Container(
              padding: gapSymmetric(horizontal: 18, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(h(36)),
                border: Border.all(color: const Color(0xffD4D2D2)),
              ),
              child: Text(
                widget.date,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: t(12),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        AnimatedRotation(
          turns: _isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: SvgPicture.asset(AppAssets.downArrow),
        ),
      ],
    );
  }
}
