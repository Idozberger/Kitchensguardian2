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

  /// KG-16: estimated per-unit weight in grams for discrete/count goods
  /// (e.g. "1 can ~400g"). Null when there is nothing to estimate. Read-only —
  /// a display hint carried through the scan-review UI.
  double? estimatedWeightGrams;

  PantryItem({
    required this.nameController,
    required this.qtyController,
    required this.expireDate,
    required this.manuFacturingDate,
    this.unit,
    this.pantry,
    this.file,
    this.fileBytes,
    this.estimatedWeightGrams,
  });
}
