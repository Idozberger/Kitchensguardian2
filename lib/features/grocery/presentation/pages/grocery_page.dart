import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/home/presentation/widgets/rounded_text_container.dart';

class GroceryPage extends StatefulWidget {
  const GroceryPage({super.key});

  @override
  State<GroceryPage> createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    "Requested Items",
    "Ai Generated List",
    "Final List",
  ];

  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _searchController,
                isFilled: true,
                fillColor: Colors.white,
                prefixIcon: Padding(
                  padding: gapAll(12),
                  child: SvgPicture.asset(AppAssets.searchSvg),
                ),
                label: '',
                hintText: "Search",
              ),
              SizedBox(height: h(15)),

              Wrap(
                spacing: w(10),
                runSpacing: h(10),
                children: List.generate(categories.length, (index) {
                  final isSelected = _selectedIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: RoundedTextContainer(
                      isBordered: true,
                      borderColor: Color(0xffD4D2D2),
                      horizontalPad: 15,
                      verticalPad: 12,
                      text: categories[index],
                      backgroundColor: isSelected
                          ? AppColors.primaryColor
                          : null,
                      textColor: Colors.black,
                    ),
                  );
                }),
              ),
              Padding(
                padding: gapOnly(top: 100),
                child: EmptyStateWidget(
                  context,
                  imagePath: AppAssets.groceryEmpty,
                  title: 'Your grocery list is empty',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
