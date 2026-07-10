import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/domain/entities/pantry_item.dart';
import 'package:foodkitchen/core/common/units/unit_system.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/navigation/paywall_navigation.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/safe_image.dart';
import 'package:foodkitchen/features/pantry/presentation/pages/my_pantry/my_pantry_filter_sheet.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/pantry_item_card_dialogs.dart';
import 'package:foodkitchen/features/pantry/presentation/widgets/pantry_item_card_inline_widgets.dart';

part 'pantry_item_card_part.dart';

class PantryItemCard extends StatefulWidget {
  final Uint8List thumbnail;
  final String title;
  final String quantity;
  final PantryFilter selectedFilter;
  final String unit;
  final String pantry;
  final VoidCallback onListCheckedCallback;
  final VoidCallback onCartItem;
  final String expiry;
  final PantryItemEntity pantryItemEntity;
  final String kitchenId;
  final bool isLocked;

  const PantryItemCard({
    super.key,
    required this.title,
    required this.quantity,
    required this.thumbnail,
    required this.unit,
    required this.pantry,
    required this.expiry,
    required this.onListCheckedCallback,
    required this.onCartItem,
    required this.selectedFilter,
    required this.pantryItemEntity,
    required this.kitchenId,
    required this.isLocked,
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
        if (widget.isLocked) {
          openPaywallIfEnabled(context);
        } else {
          setState(() => _isExpanded = !_isExpanded);
        }
        FocusScope.of(context).unfocus();
      },
      child: Container(
        margin: gapSymmetric(vertical: 0),
        padding: gapAll(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(h(10)),
          border: Border.all(color: const Color(0xffD4D2D2)),
        ),
        child: pantryItemCardBody(context),
      ),
    );
  }
}
