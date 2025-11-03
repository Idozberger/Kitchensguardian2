import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/services/image_picker/image_picker_service.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/dashboard/presentation/widgets/circular_icon_button.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_event.dart';
import 'package:foodkitchen/features/profile/presentation/bloc/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late ProfileBloc profileBloc;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void initState() {
    profileBloc = context.read<ProfileBloc>();

    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await ImagePickerService.pickFromGallery(context);
    if (image != null) {
      profileBloc.add(UpdateProfilePicture(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
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
                  children: [
                    Center(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          state.imagePath != null
                              ? CircleAvatar(
                                  radius: w(36),
                                  backgroundColor: Colors.grey.shade200,

                                  backgroundImage: MemoryImage(
                                    state.imagePath!,
                                  ),
                                )
                              : Image.asset(
                                  AppAssets.avatar,
                                  width: w(72),
                                  height: h(72),
                                ),

                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: EdgeInsets.all(w(4)),
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                                child: SvgPicture.asset(
                                  AppAssets.editSvg,
                                  width: w(16),
                                  height: h(16),
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    gap(height: 20),

                    UpperTile(
                      widget: Column(
                        children: [
                          AppTextField(
                            textInputAction: TextInputAction.next,
                            controller: _firstNameController,
                            label: "First Name",
                            keyboardType: TextInputType.text,
                            hintText: "Enter your first name",
                          ),
                          SizedBox(height: h(20)),
                          AppTextField(
                            textInputAction: TextInputAction.done,
                            controller: _lastNameController,
                            label: "Last Name",
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
                          AppToast.show(
                            "Successfully Changed!",
                            ToastType.success,
                          );
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
        "Edit Profile",
        style: Theme.of(context).textTheme.headlineLarge,
      ),
    );
  }
}
