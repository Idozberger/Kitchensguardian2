import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/common/cubits/user_cubit.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_container_checktile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_segmented_progress_bar_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_bloc.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_event.dart';
import 'package:foodkitchen/features/grocery/presentation/bloc/grocery_state.dart';
import 'package:foodkitchen/features/home/presentation/widgets/no_kitchen_found.dart';
import 'package:foodkitchen/features/home/presentation/widgets/rounded_text_container.dart';

class GroceryPage extends StatefulWidget {
  const GroceryPage({super.key});

  @override
  State<GroceryPage> createState() => _GroceryPageState();
}

class _GroceryPageState extends State<GroceryPage> {
  late final UserCubit userCubit;
  late final GroceryBloc groceryBloc;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> requestedItems = [
    {"title": "Chicken Breast (1/2 kg)", "checked": true},
    {"title": "Milk (1 liter)", "checked": true},
    {"title": "Eggs (1 box)", "checked": false},
    {"title": "Bread (1 pack)", "checked": false},
  ];

  final List<Map<String, dynamic>> aiGeneratedItems = [
    {"title": "Eggs (1 box)", "checked": false},
    {"title": "Bread (1 pack)", "checked": false},
  ];

  final List<Map<String, dynamic>> finalListItems = [];
  final List<String> categories = [
    "Requested Items",
    "AI Generated List",
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
  void initState() {
    super.initState();
    userCubit = context.read<UserCubit>();
    groceryBloc = context.read<GroceryBloc>();
    _fetchRequestedItems();
  }

  Future<void> _fetchRequestedItems() async {
    String activeKitchenId = userCubit.state.activeKitchenId;
    if (activeKitchenId.isNotEmpty) {
      groceryBloc.add(RequestedGroceryEvent(kitchenId: activeKitchenId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GroceryBloc, GroceryState>(
      listener: (context, state) {
        if (state is GroceryFailure) {
          AppToast.show(state.message, ToastType.error);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xffF9F9F9),
          body: SafeArea(
            child: Padding(
              padding: gapSymmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  gap(height: 15),
                  _buildCategoryTabs(),
                  gap(height: 16),
                  Expanded(child: _buildContent(state)),
                ],
              ),
            ),
          ),
        );
      },
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
      hintText: "Search",
      label: '',
      isLabled: false,
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: h(44),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final isSelected = _selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: RoundedTextContainer(
                isBordered: true,
                borderColor: isSelected
                    ? AppColors.primaryColor
                    : const Color(0xffD4D2D2),
                horizontalPad: 15,
                verticalPad: 12,
                text: categories[index],
                backgroundColor: isSelected
                    ? AppColors.primaryColor
                    : Colors.white,
                textColor: Colors.black,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(GroceryState state) {
    if (state is GroceryLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primaryColor),
      );
    }

    if (state is RequestedGroceryLoaded) {
      if (state.requestedItemsList.isEmpty) {
        return Center(
          child: EmptyStateWidget(
            context,
            imagePath: AppAssets.groceryEmpty,
            title: 'Your grocery list is empty',
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildItemList(state)),
          gap(height: 20),
          _buildFooter(state),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildItemList(RequestedGroceryLoaded state) {
    final items = state.requestedItemsList;

    return ListView.separated(
      shrinkWrap: true,
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(color: Color(0xffF4F4F4)),
      itemBuilder: (context, index) {
        final grocery = items[index];
        final isChecked = (index < currentItems.length)
            ? currentItems[index]["checked"]
            : false;

        return UpperTile(
          widget: GenericCircleCheckboxTile(
            title: grocery.name,
            isChecked: isChecked,

            activeColor: AppColors.primaryColor,
            onChanged: (value) {
              setState(() => currentItems[index]["checked"] = value);
            },
          ),
        );
      },
    );
  }

  Widget _buildFooter(GroceryState state) {
    if (_selectedIndex != 2) {
      if (state is RequestedGroceryLoaded &&
          state.requestedItemsList.isNotEmpty) {
        return GenericButtonWidget(
          text: "Add to Final List",
          onPressed: () {
            setState(() {
              finalListItems.clear();
              finalListItems.addAll(currentItems);
              _selectedIndex = 2;
            });
          },
        );
      }
      return const SizedBox.shrink();
    }

    if (finalListItems.isEmpty) return const SizedBox.shrink();

    final completedCount = finalListItems
        .where((e) => e["checked"] == true)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$completedCount/${finalListItems.length} items completed",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        gap(height: 20),
        SegmentedProgressBar(
          total: finalListItems.length,
          completed: completedCount,
        ),
        gap(height: 20),
        _buildShareButton(),
      ],
    );
  }

  Widget _buildShareButton() {
    return SizedBox(
      width: double.infinity,
      height: h(40),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          if (finalListItems.isEmpty) return;
          final text = finalListItems.map((e) => e["title"]).join('\n');
          await Share.share(text, subject: 'Grocery List');
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
