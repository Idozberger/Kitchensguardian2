import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/dialogs/generic_dialog.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<bool> _requestPermissions(BuildContext context) async {
    await [
      Permission.camera,
      Platform.isAndroid ? Permission.storage : Permission.photos,
    ].request();
    return true;
  }

  static Future<File?> pickFromGallery(BuildContext context) async {
    final hasPermission = await _requestPermissions(context);
    if (!hasPermission) return null;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    return image != null ? File(image.path) : null;
  }

  static Future<File?> pickFromCamera(BuildContext context) async {
    final hasPermission = await _requestPermissions(context);
    if (!hasPermission) return null;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    return image != null ? File(image.path) : null;
  }

  static Future<File?> showImageSourceDialog(BuildContext context) async {
    return showDialog<File>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return GenericDialog(
          borderRadius: h(20),
          child: Padding(
            padding: gapAll(4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Image Source',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                SizedBox(height: h(8)),
                Text(
                  'Choose whether to take a new photo or select one from the gallery.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: h(12)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircleButton(
                      context,
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () async {
                        // Same bottom-sheet context used after picker future; sheet still mounted.
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context, await pickFromCamera(context));
                      },
                    ),

                    _buildCircleButton(
                      context,
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () async {
                        // Same bottom-sheet context used after picker future; sheet still mounted.
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context, await pickFromGallery(context));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildCircleButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(h(40)),
          child: Container(
            height: h(50),
            width: h(50),
            decoration: BoxDecoration(
              shape: BoxShape.circle,

              border: Border.all(color: AppColors.primaryColor, width: 1.5),
            ),
            child: Icon(icon, color: AppColors.primaryColor, size: t(28)),
          ),
        ),
        SizedBox(height: h(8)),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontSize: t(12),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
