import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/document_scanning/document_scanning_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:go_router/go_router.dart';

AppBar buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    leadingWidth: w(55),
    leading: _buildBackButton(context),
    title: Text("My Pantry", style: Theme.of(context).textTheme.headlineLarge),
    bottom: PreferredSize(
      preferredSize: Size.fromHeight(h(70)),
      child: Padding(
        padding: gapSymmetric(horizontal: 20, vertical: 10),
        child: Row(
          spacing: w(10),
          children: [
            Expanded(child: _buildScanButton(context)),
            Expanded(child: _buildAddItemButton(context)),
          ],
        ),
      ),
    ),
  );
}

Widget _buildBackButton(BuildContext context) {
  return Row(
    children: [
      SizedBox(width: w(16)),
      CircularIconButton(
        iconAsset: AppAssets.backArrowiOS,
        onTap: () => Navigator.pop(context),
      ),
    ],
  );
}

Widget _buildScanButton(BuildContext context) {
  return SizedBox(
    height: h(40),
    child: OutlinedButton.icon(
      onPressed: () =>
          DocumentScannerService().scanDocument(context, replacement: true),
      icon: SvgPicture.asset(AppAssets.scanSvg, height: h(18), width: w(18)),
      label: Text(
        "Scan",
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: t(12),
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

Widget _buildAddItemButton(BuildContext context) {
  return SizedBox(
    height: h(40),
    child: ElevatedButton.icon(
      onPressed: () => context.push(Routes.addItem),
      icon: SvgPicture.asset(AppAssets.addSvg, height: h(18), width: w(18)),
      label: Text(
        "Add Item",
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: t(12),
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
