import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';

class SearchBarWidgetForGenerateRecipes extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearchTap;

  const SearchBarWidgetForGenerateRecipes({
    super.key,
    required this.controller,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      fillColor: Colors.white,
      isFilled: true,
      isLabled: false,
      label: "",
      onFieldSubmitted: (_) => onSearchTap(),
      controller: controller,
      hintText: "e.g Fries",
      suffixIcon: GestureDetector(
        onTap: onSearchTap,
        child: Padding(
          padding: gapAll(h(6)),
          child: CircleAvatar(
            backgroundColor: AppColors.primaryColor,
            child: SvgPicture.asset(
              AppAssets.searchSvg,
              color: Colors.black,
              height: h(15),
            ),
          ),
        ),
      ),
    );
  }
}
