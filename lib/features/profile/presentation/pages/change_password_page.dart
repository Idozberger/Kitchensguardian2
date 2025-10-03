import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: gapSymmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                UpperTile(
                  widget: Column(
                    children: [
                      AppTextField(
                        controller: _newPasswordController,
                        label: "New Password",

                        keyboardType: TextInputType.text,
                        hintText: "Enter new password",
                      ),

                      SizedBox(height: h(20)),
                      AppTextField(
                        controller: _confirmPasswordController,
                        label: "Confirm Password",

                        hintText: "Renter new password",
                      ),
                    ],
                  ),
                ),
                gap(height: 20),
                GenericButtonWidget(
                  onPressed: () {
                    if (_newPasswordController.text.trim().isEmpty) {
                      AppToast.show(
                        "Please enter your new password",
                        ToastType.error,
                      );
                    } else if (_confirmPasswordController.text.trim().isEmpty) {
                      AppToast.show(
                        "Please enter your confirm password",
                        ToastType.error,
                      );
                    } else if (_newPasswordController.text.trim() !=
                        _confirmPasswordController.text.trim()) {
                      AppToast.show("Passwords do not match", ToastType.error);
                    } else {
                      AppToast.show("Successfully Changed!", ToastType.success);
                      Navigator.pop(context);
                    }
                  },
                  text: "Confirm",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: w(55),
      leading: Row(
        children: [
          SizedBox(width: w(16)),
          CircularIconButton(
            iconAsset: AppAssets.backArrowiOS,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
      title: Text(
        "Change Password",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
