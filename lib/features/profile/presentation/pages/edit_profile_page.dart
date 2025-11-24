// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
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
  late UserCubit userCubit;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  Uint8List? imageBytes;
  @override
  void initState() {
    profileBloc = context.read<ProfileBloc>();
    userCubit = context.read<UserCubit>();
    _firstNameController.text = userCubit.state.firstName;
    _lastNameController.text = userCubit.state.lastName;
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
      imageBytes = image.readAsBytesSync();
      setState(() {});
      // profileBloc.add(UpdateProfilePicture(image.path));
    }
  }

  Future<void> _saveUser() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    final firstNameError = _validateName(firstName, 'First name');
    if (firstNameError != null) {
      AppToast.show(firstNameError, ToastType.error);
      return;
    }

    final lastNameError = _validateName(lastName, 'Last name');
    if (lastNameError != null) {
      AppToast.show(lastNameError, ToastType.error);
      return;
    }

    String? base64Thumbnail;

    if (imageBytes != null) {
      base64Thumbnail = await compressImage(imageBytes!);
    } else {
      AppToast.show("Please select a profile picture", ToastType.error);
      return;
    }

    profileBloc.add(
      EditProfileEvent(
        firstName: firstName,
        lastName: lastName,
        thumbnail: base64Thumbnail,
      ),
    );
  }

  Future<String> compressImage(Uint8List bytes) async {
    final result = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 800,
      minHeight: 600,
      quality: 15,
      rotate: 0,
      autoCorrectionAngle: true,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    String base64Thumbnail = base64Encode(result);
    return "data:image/jpeg;base64,$base64Thumbnail";
  }

  String? _validateName(String name, String fieldName) {
    if (name.isEmpty || name.length < 3) {
      return '$fieldName must be at least 3 characters long';
    }

    if (name.length > 10) {
      return '$fieldName must not exceed 10 characters';
    }

    if (name.split(RegExp(r'\s+')).length > 2) {
      return '$fieldName can contain up to 2 words only';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          AppToast.show(state.successMessage!, ToastType.success);
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
                      isLoading: state.isLoading,
                      onPressed: () => _saveUser(),
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
