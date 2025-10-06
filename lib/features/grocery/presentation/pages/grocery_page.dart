import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_checktile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_segmented_progress_bar_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/home/presentation/widgets/rounded_text_container.dart';
import 'package:share_plus/share_plus.dart';

class GroceryPage extends StatefulWidget {
  const GroceryPage({super.key});

  @override
  State<GroceryPage> createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> requestedItems = [
    {"title": "Chicken Breast ( 1/2 kg )", "checked": true},
    {"title": "Milk ( 1 liter )", "checked": true},
    {"title": "Eggs ( 1 box )", "checked": false},
    {"title": "Bread ( 1 pack )", "checked": false},
  ];

  final List<Map<String, dynamic>> aiGeneratedItems = [
    {"title": "Eggs ( 1 box )", "checked": false},
    {"title": "Bread ( 1 pack )", "checked": false},
  ];

  final List<Map<String, dynamic>> finalListItems = [];

  final List<String> categories = [
    "Requested Items",
    "Ai Generated List",
    "Final List",
  ];

  int _selectedIndex = 0;

  List<Map<String, dynamic>> get currentItems {
    switch (_selectedIndex) {
      case 0:
        return requestedItems;
      case 1:
        return aiGeneratedItems;
      case 2:
        return finalListItems;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9F9),
      body: SafeArea(
        child: Padding(
          padding: gapSymmetric(horizontal: 20, vertical: 14),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(),
                gap(height: 15),
                _buildCategoryTabs(),
                if (_selectedIndex == 2) ...[
                  gap(height: 20),
                  GenericButtonWidget(
                    onPressed: () {},
                    text: "+ Add Custom Items",
                  ),
                ],
                gap(height: 16),
                _buildItemList(),
                gap(height: 20),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AppTextField(
      controller: _searchController,
      isFilled: true,
      fillColor: Colors.white,
      prefixIcon: Padding(
        padding: gapAll(12),
        child: SvgPicture.asset(AppAssets.searchSvg),
      ),
      label: '',
      isLabled: false,
      hintText: "Search",
    );
  }

  Widget _buildCategoryTabs() {
    return Wrap(
      spacing: w(10),
      runSpacing: h(10),
      children: List.generate(categories.length, (index) {
        final isSelected = _selectedIndex == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedIndex = index),
          child: RoundedTextContainer(
            isBordered: true,
            borderColor: const Color(0xffD4D2D2),
            horizontalPad: 15,
            verticalPad: 12,
            text: categories[index],
            backgroundColor: isSelected ? AppColors.primaryColor : null,
            textColor: Colors.black,
          ),
        );
      }),
    );
  }

  Widget _buildItemList() {
    if (currentItems.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          context,
          imagePath: AppAssets.groceryEmpty,
          title: 'Your grocery list is empty',
        ),
      );
    }

    return UpperTile(
      widget: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currentItems.length,
        separatorBuilder: (_, __) => Padding(
          padding: gapOnly(top: 15, bottom: 10),
          child: const Divider(color: Color(0xffF4F4F4)),
        ),
        itemBuilder: (context, index) {
          final item = currentItems[index];
          return GenericCircleCheckboxTile(
            title: item["title"] as String,
            isChecked: item["checked"] as bool,
            activeColor: AppColors.primaryColor,
            onChanged: (value) {
              setState(() => currentItems[index]["checked"] = value);
            },
          );
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    if (_selectedIndex != 2) {
      return GenericButtonWidget(
        onPressed: () {
          setState(() {
            finalListItems.addAll(
              currentItems.where((item) => item["checked"] == true),
            );
            _selectedIndex = 2;
          });
        },
        text: "Add to final list",
      );
    }

    if (currentItems.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "2/4 items completed",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        gap(height: 20),
        SegmentedProgressBar(total: 4, completed: 2),
        gap(height: 20),
        _buildShareButton(context),
      ],
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: h(40),
      child: ElevatedButton.icon(
        onPressed: () async {
          await Share.share(
            finalListItems.map((item) => item["title"] as String).join('\n'),
            subject: 'Grocery List',
          );
        },
        icon: SvgPicture.asset(AppAssets.shareSvg),
        label: Text(
          "Share List",
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontSize: t(14),
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
