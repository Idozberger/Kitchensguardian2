import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      isFilled: true,
      onChanged: onChanged,
      fillColor: Colors.white,
      prefixIcon: Padding(
        padding: gapAll(12),
        child: SvgPicture.asset(AppAssets.searchSvg),
      ),
      hintText: "Search",
      label: '',
      isLabled: false,
    );
  }
}
