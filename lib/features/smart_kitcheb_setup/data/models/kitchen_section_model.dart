import 'package:flutter/material.dart';

class KitchenSection {
  final String id;
  final String title;
  final String subtitle;
  final String hint;
  final String? tip;
  final String icon;
  final Color accent;
  List<String> imagePaths;
  bool get isComplete => imagePaths.isNotEmpty;

  KitchenSection({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.hint,
    required this.icon,
    required this.accent,
    this.tip,
    this.imagePaths = const [],
  });

  KitchenSection copyWith({List<String>? imagePaths}) => KitchenSection(
    id: id,
    title: title,
    subtitle: subtitle,
    hint: hint,
    icon: icon,
    accent: accent,
    imagePaths: imagePaths ?? this.imagePaths,
  );
}
