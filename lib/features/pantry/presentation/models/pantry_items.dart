import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PantryItem {
  File? file;
  Uint8List? fileBytes;
  final TextEditingController nameController;
  final TextEditingController qtyController;
  final TextEditingController manuFacturingDate;
  final TextEditingController expireDate;
  String? unit;
  String? pantry;
  bool needsReview = false;

  PantryItem({
    required this.nameController,
    required this.qtyController,
    required this.expireDate,
    required this.manuFacturingDate,
    this.unit,
    this.pantry,
    this.file,
    this.fileBytes,
  });
}
