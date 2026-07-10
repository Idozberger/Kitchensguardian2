import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/safe_image.dart';

class ImagePreviewWidget extends StatelessWidget {
  final String imagePath;
  const ImagePreviewWidget({required this.imagePath, super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: h(458),
        width: w(400),
        color: Colors.black,
        child: SafeFileImage(
          file: File(imagePath),
          fit: BoxFit.cover,
          fallback: const Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.white54,
              size: 48,
            ),
          ),
        ),
      ),
    );
  }
}
