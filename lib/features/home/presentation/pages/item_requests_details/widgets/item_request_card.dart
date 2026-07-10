import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/domain/entities/item_request.dart';
import 'package:foodkitchen/features/home/presentation/bloc/home_state.dart';
import 'package:foodkitchen/features/home/presentation/pages/item_requests_details/widgets/card_expanded_content.dart';
import 'package:foodkitchen/features/home/presentation/pages/item_requests_details/widgets/dot.dart';
import 'package:foodkitchen/features/home/presentation/pages/item_requests_details/widgets/inline_text.dart';

class ItemRequestCard extends StatefulWidget {
  final ItemRequest request;
  final HomeState state;

  const ItemRequestCard({
    super.key,
    required this.request,
    required this.state,
  });

  @override
  State<ItemRequestCard> createState() => _ItemRequestCardState();
}

class _ItemRequestCardState extends State<ItemRequestCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isPending = widget.request.status == 'pending';

    return GestureDetector(
      onTap: () {
        setState(() => _isExpanded = !_isExpanded);
        FocusScope.of(context).unfocus();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: h(10)),
        padding: EdgeInsets.all(w(15)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(h(10)),
          border: Border.all(color: const Color(0xffD4D2D2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(height: h(1), width: double.maxFinite),
                Positioned(
                  top: -h(22),
                  right: w(38),
                  child: Badge(
                    backgroundColor: widget.request.status == "approved"
                        ? Colors.green
                        : widget.request.status == "rejected"
                        ? Colors.red
                        : Colors.grey,
                    label: Padding(
                      padding: gapAll(2),
                      child: Text(
                        widget.request.status[0].toUpperCase() +
                            widget.request.status.substring(1),
                      ),
                    ),
                    child: Container(),
                  ),
                ),
              ],
            ),
            _CardHeader(request: widget.request, isExpanded: _isExpanded),
            if (_isExpanded) ...[
              gap(height: 12),
              CardExpandedContent(
                request: widget.request,
                state: widget.state,
                isPending: isPending,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final ItemRequest request;
  final bool isExpanded;

  const _CardHeader({required this.request, required this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _ItemAvatar(),
            gap(width: 8),
            SizedBox(
              width: isExpanded ? w(200) : w(54),
              child: Text(
                request.name,
                maxLines: isExpanded ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            if (!isExpanded) _CardInlineInfo(request: request),
          ],
        ),
        AnimatedRotation(
          turns: isExpanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: SvgPicture.asset(AppAssets.downArrow),
        ),
      ],
    );
  }
}

class _ItemAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: h(28),
      width: h(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(h(24)),
      ),
      child: Icon(Icons.food_bank, size: h(16), color: Colors.grey.shade500),
    );
  }
}

class _CardInlineInfo extends StatelessWidget {
  final ItemRequest request;

  const _CardInlineInfo({required this.request});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: w(38),
          child: Align(
            alignment: Alignment.topRight,
            child: InlineText(text: request.quantity.toString()),
          ),
        ),
        Dot(),
        SizedBox(
          width: w(18),
          child: InlineText(text: unitDisplayLabel(request.unit)),
        ),
        Dot(),
        SizedBox(
          width: w(54),
          child: InlineText(text: request.group),
        ),
      ],
    );
  }
}
