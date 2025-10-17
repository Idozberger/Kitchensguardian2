import 'package:flutter/material.dart';

class PantryItem {
  final TextEditingController nameController;
  final TextEditingController qtyController;
  String? unit;
  String? pantry;

  PantryItem({
    required this.nameController,
    required this.qtyController,
    this.unit,
    this.pantry,
  });
}
