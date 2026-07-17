part of 'package:foodkitchen/features/pantry/presentation/widgets/pantry_item_card.dart';

extension _PantryItemCardLayout on _PantryItemCardState {
  Widget pantryItemCardBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: h(1)),
        if (!widget.isLocked && widget.selectedFilter != PantryFilter.all) ...[
          if (widget.pantryItemEntity.expiryStatus == "expiring_soon" ||
              widget.pantryItemEntity.stockStatus == "low_stock")
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(height: h(1), width: double.maxFinite),
                Positioned(
                  top: -h(22),
                  right:
                      widget.pantryItemEntity.expiryStatus == "expiring_soon" &&
                          widget.pantryItemEntity.stockStatus == "low_stock"
                      ? w(134)
                      : widget.pantryItemEntity.stockStatus == "low_stock" &&
                            widget.pantryItemEntity.expiryStatus !=
                                "expiring_soon"
                      ? w(54)
                      : w(62),
                  child: Badge(
                    label: Padding(
                      padding: gapAll(2),
                      child: Text(
                        widget.pantryItemEntity.expiryStatus ==
                                    "expiring_soon" &&
                                widget.pantryItemEntity.stockStatus ==
                                    "low_stock"
                            ? "Expiring soon and low-stock"
                            : widget.pantryItemEntity.expiryStatus ==
                                  "expiring_soon"
                            ? "Expiring soon"
                            : "Running low",
                      ),
                    ),
                    child: Container(),
                  ),
                ),
              ],
            ),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(h(24)),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: widget.isLocked ? 6 : 0,
                      sigmaY: widget.isLocked ? 6 : 0,
                    ),
                    child: SafeMemoryImage(
                      bytes: widget.thumbnail,
                      height: h(28),
                      width: h(28),
                      fit: BoxFit.cover,
                      fallback: SafeNetworkImage(
                        url: widget.pantryItemEntity.iconUrl,
                        height: h(28),
                        width: h(28),
                        fit: BoxFit.cover,
                        fallback: Container(
                          height: h(28),
                          width: h(28),
                          alignment: Alignment.center,
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.food_bank,
                            size: h(16),
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                gap(width: 8),
                SizedBox(
                  width: _isExpanded ? w(244) : w(54),
                  child: widget.isLocked
                      ? ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Text(
                            widget.title,
                            maxLines: _isExpanded ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineLarge,
                          ),
                        )
                      : Text(
                          widget.title,
                          maxLines: _isExpanded ? 2 : 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                ),
                if (!_isExpanded) ...[
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: widget.isLocked ? 5 : 0,
                      sigmaY: widget.isLocked ? 5 : 0,
                    ),
                    child: Opacity(
                      opacity: widget.isLocked ? 0.5 : 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: w(38),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: pantryItemCardInlineInfo(
                                context,
                                widget.quantity,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: w(24),
                            child: pantryItemCardDot(context),
                          ),
                          SizedBox(
                            width: w(38),
                            child: pantryItemCardInlineInfo(
                              context,
                              unitDisplayLabel(widget.unit),
                            ),
                          ),
                          SizedBox(
                            width: w(24),
                            child: pantryItemCardDot(context),
                          ),
                          SizedBox(
                            width: w(54),
                            child: pantryItemCardInlineInfo(
                              context,
                              widget.pantry,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            AnimatedRotation(
              turns: _isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: widget.isLocked ? 4 : 0,
                  sigmaY: widget.isLocked ? 4 : 0,
                ),
                child: SvgPicture.asset(AppAssets.downArrow),
              ),
            ),
          ],
        ),
        if (_isExpanded) ...[
          SizedBox(height: h(15)),
          Row(
            children: [
              pantryItemCardInlineInfo(
                context,
                widget.quantity,
                isExpanded: true,
              ),
              pantryItemCardDot(context),
              pantryItemCardInlineInfo(
                context,
                unitDisplayLabel(widget.unit),
                isExpanded: true,
              ),
              pantryItemCardDot(context),
              pantryItemCardInlineInfo(
                context,
                widget.pantry,
                isExpanded: true,
              ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              pantryItemCardCircleButton(AppAssets.editSvg, () {
                showPantryItemEditDialog(
                  context,
                  widget.pantryItemEntity,
                  widget.kitchenId,
                );
              }),
              pantryItemCardCircleButton(AppAssets.cartSvg, widget.onCartItem),
              pantryItemCardCircleButton(AppAssets.deleteSvg, () {
                showPantryItemDeleteDialog(
                  context,
                  widget.pantryItemEntity,
                  widget.kitchenId,
                );
              }),
            ],
          ),
        ],
        if (widget.isLocked) const PantryItemCardLockOverlay(),
      ],
    );
  }
}
