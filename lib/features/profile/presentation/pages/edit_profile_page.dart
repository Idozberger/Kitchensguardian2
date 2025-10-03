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

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
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
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.asset(
                        AppAssets.avatar,
                        width: w(72),
                        height: h(72),
                      ),
                      Positioned(
                        bottom: h(-0),
                        right: w(-8),
                        child: SvgPicture.asset(
                          AppAssets.editSvg,
                          width: w(16),
                          height: h(16),
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                gap(height: 15),
                UpperTile(
                  widget: Column(
                    children: [
                      AppTextField(
                        controller: _firstNameController,
                        label: "First Name",

                        keyboardType: TextInputType.text,
                        hintText: "Enter your first name",
                      ),

                      SizedBox(height: h(20)),
                      AppTextField(
                        controller: _lastNameController,
                        label: "Last name",

                        hintText: "Enter your last name",
                      ),
                    ],
                  ),
                ),
                gap(height: 20),
                GenericButtonWidget(
                  onPressed: () {
                    if (_firstNameController.text.trim().isEmpty) {
                      AppToast.show(
                        "Please enter your first name",
                        ToastType.error,
                      );
                    } else if (_lastNameController.text.trim().isEmpty) {
                      AppToast.show(
                        "Please enter your last name",
                        ToastType.error,
                      );
                    } else {
                      AppToast.show("Successfully Changed!", ToastType.success);
                      Navigator.pop(context);
                    }
                  },
                  text: "Save",
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
        "Edit Profile",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
