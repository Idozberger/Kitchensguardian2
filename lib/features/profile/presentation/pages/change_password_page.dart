import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_event.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_state.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isObscurePassword = false;
  bool _isObscureConfirmPassword = false;
  bool _currentPasswordObscure = false;
  void updateCurrentPasswordObscure() {
    setState(() {
      _currentPasswordObscure = !_currentPasswordObscure;
    });
  }

  void updateObsecurePassword() {
    setState(() {
      _isObscurePassword = !_isObscurePassword;
    });
  }

  void updateObsecureConfirmPassword() {
    setState(() {
      _isObscureConfirmPassword = !_isObscureConfirmPassword;
    });
  }

  void onUpdatePassword() {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    final currentError = _validatePassword(currentPassword, "current password");
    if (currentError != null) {
      AppToast.show(currentError, ToastType.error);
      return;
    }

    final newError = _validatePassword(newPassword, "new password");
    if (newError != null) {
      AppToast.show(newError, ToastType.error);
      return;
    }

    final confirmError = _validatePassword(confirmPassword, "confirm password");
    if (confirmError != null) {
      AppToast.show(confirmError, ToastType.error);
      return;
    }

    if (newPassword != confirmPassword) {
      AppToast.show("Passwords do not match", ToastType.error);
      return;
    }

    changePassword(currentPassword: currentPassword, newPassword: newPassword);
  }

  void changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    context.read<ProfileBloc>().add(
      ChangePasswordEvent(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ),
    );
  }

  String? _validatePassword(String value, String fieldName) {
    if (value.isEmpty) return "Please enter your $fieldName";
    if (value.length < 6) {
      return "$fieldName must be at least 6 characters long";
    }
    return null;
  }

  void resetState() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (_, state) {
        if (state.successMessage != null) {
          AppToast.show(state.successMessage!, ToastType.success);
          resetState();
        }
        if (state.errorMessage != null) {
          AppToast.show(state.errorMessage!, ToastType.error);
        }
      },
      builder: (_, state) {
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
                            controller: _currentPasswordController,
                            label: "Current Password",
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            hintText: "Enter current password",
                            obscureText: !_currentPasswordObscure,
                            suffixIcon: GestureDetector(
                              onTap: () => updateCurrentPasswordObscure(),
                              child: Padding(
                                padding: gapSymmetric(
                                  vertical: 13,
                                  horizontal: 15,
                                ),
                                child: SvgPicture.asset(
                                  AppAssets.eyeVisibilitySvg,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: h(20)),
                          AppTextField(
                            controller: _newPasswordController,
                            label: "New Password",
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            hintText: "Enter new password",
                            obscureText: !_isObscurePassword,
                            suffixIcon: GestureDetector(
                              onTap: () => updateObsecurePassword(),
                              child: Padding(
                                padding: gapSymmetric(
                                  vertical: 13,
                                  horizontal: 15,
                                ),
                                child: SvgPicture.asset(
                                  AppAssets.eyeVisibilitySvg,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: h(20)),
                          AppTextField(
                            controller: _confirmPasswordController,
                            label: "Confirm Password",
                            textInputAction: TextInputAction.done,
                            hintText: "Renter new password",
                            obscureText: !_isObscureConfirmPassword,
                            suffixIcon: GestureDetector(
                              onTap: () => updateObsecureConfirmPassword(),
                              child: Padding(
                                padding: gapSymmetric(
                                  vertical: 13,
                                  horizontal: 15,
                                ),
                                child: SvgPicture.asset(
                                  AppAssets.eyeVisibilitySvg,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    gap(height: 20),
                    GenericButtonWidget(
                      isLoading: state.isLoading,
                      onPressed: () => onUpdatePassword(),
                      text: "Confirm",
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
