import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class PantryItem {
  File? file;
  Uint8List? fileBytes;

  /// Raw base64 thumbnail from a scan response, left un-decoded until
  /// [displayBytes] is first read (a receipt can have 50-100+ items, and
  /// only the ones actually scrolled into view need decoding).
  String? thumbnailBase64;

  final TextEditingController nameController;
  final TextEditingController qtyController;
  final TextEditingController manuFacturingDate;
  final TextEditingController expireDate;
  String? unit;
  String? pantry;
  bool needsReview = false;

  /// Set when [nameController]'s value was picked from the shared ingredient
  /// catalog search; cleared as soon as the user edits the name by hand.
  String? sharedIngredientId;

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
    this.thumbnailBase64,
    this.estimatedWeightGrams,
  });

  /// Decodes [thumbnailBase64] into [fileBytes] on first access and caches
  /// the result, so repeated rebuilds (e.g. scrolling a row off/on screen)
  /// don't repeatedly pay the decode cost.
  Uint8List? get displayBytes {
    if (fileBytes == null &&
        thumbnailBase64 != null &&
        thumbnailBase64!.isNotEmpty) {
      try {
        fileBytes = base64Decode(thumbnailBase64!);
      } catch (_) {
        fileBytes = Uint8List(0);
      }
    }
    return fileBytes;
  }
}
