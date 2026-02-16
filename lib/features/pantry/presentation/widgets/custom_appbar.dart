// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/config/routes.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/document_scanning/document_scanning_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class MyPantryAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MyPantryAppBar({super.key});

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + h(54));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leadingWidth: w(55),
      leading: _buildBackButton(context),
      title: Text(
        "My Pantry",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
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
          onTap: () => context.pushNamed(Routes.dashboard),
        ),
      ],
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return SizedBox(
      height: h(40),
      child: OutlinedButton.icon(
        onPressed: () => _scanDocument(context),
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
        onPressed: () => context.pushNamed(Routes.addItem),
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

  void _scanDocument(BuildContext context) async {
    final state = context.read<UserCubit>().state;

    if (state.role == "member") {
      AppToast.show(
        "Only the host or co-host can scan receipts.",
        ToastType.error,
        gravity: ToastGravity.TOP,
      );
      return;
    }

    final status = await Permission.camera.request();

    if (status.isGranted) {
      await DocumentScannerService().scanDocument(context);
    } else if (status.isDenied) {
      AppToast.show(
        "Camera permission is required to scan receipts.",
        ToastType.error,
        gravity: ToastGravity.TOP,
      );
    } else if (status.isPermanentlyDenied) {
      _showPermissionDialog(context, isPermanent: true);
    }
  }

  void _showPermissionDialog(BuildContext context, {bool isPermanent = false}) {
    showDialog(
      context: context,
      builder: (context) => PermissionDialog(isPermanent: isPermanent),
    );
  }
}

class PermissionDialog extends StatelessWidget {
  final bool isPermanent;

  const PermissionDialog({super.key, this.isPermanent = false});

  @override
  Widget build(BuildContext context) {
    return GenericDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            AppAssets.cameraSvg,
            height: h(44),
            width: w(44),
            color: AppColors.primaryColor,
          ),
          gapVertical(8),

          Text(
            'Camera Permission Required',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          gapVertical(8),

          Text(
            isPermanent
                ? 'Camera access is required to scan documents. Please enable it in app settings.'
                : 'This app needs camera access to scan documents and receipts.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          gapVertical(12),

          Row(
            children: [
              Flexible(
                child: GenericButtonWidget(
                  isOutlined: true,
                  onPressed: () => Navigator.pop(context),
                  text: "Cancel",
                ),
              ),

              gapHorizontal(6),
              Flexible(
                child: GenericButtonWidget(
                  onPressed: () {
                    openAppSettings();
                    Navigator.pop(context);
                  },
                  text: isPermanent ? 'Open Settings' : 'Allow',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
