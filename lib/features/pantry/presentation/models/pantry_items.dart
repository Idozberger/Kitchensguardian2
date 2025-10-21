import 'package:flutter/material.dart';

class PantryItem {
  final TextEditingController nameController;
  final TextEditingController qtyController;
  final TextEditingController manuFacturingDate;
  final TextEditingController expireDate;
  String? unit;
  String? pantry;

  PantryItem({
    required this.nameController,
    required this.qtyController,
    required this.expireDate,
    required this.manuFacturingDate,
    this.unit,
    this.pantry,
  });
}
