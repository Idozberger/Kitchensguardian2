import 'dart:io';

import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';

class ImagePreviewWidget extends StatelessWidget {
  final String imagePath;
  const ImagePreviewWidget({required this.imagePath, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: h(458),
      width: w(400),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.black,
        image: DecorationImage(
          image: FileImage(File(imagePath)),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
