import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/features/home/presentation/pages/item_requests_details/widgets/items_extension.dart';

class FilterAppBarButton extends StatelessWidget {
  final ItemRequestFilter selectedFilter;
  final VoidCallback onTap;

  const FilterAppBarButton({
    super.key,
    required this.selectedFilter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: w(16)),
      child: InkWell(
        onTap: onTap,
        child: SvgPicture.asset(AppAssets.filterSvg),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final ItemRequestFilter selectedFilter;
  final Function(ItemRequestFilter) onFilterChanged;
  final VoidCallback onApplyFilter;

  const FilterBottomSheet({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onApplyFilter,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late ItemRequestFilter _tempFilter;

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.selectedFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: gapSymmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _BottomSheetHandle(),
          gap(height: 18),
          Center(
            child: Text(
              "Filter Requests",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          gap(height: 20),
          ...ItemRequestFilter.values.map(
            (filter) => Padding(
              padding: EdgeInsets.only(bottom: h(12)),
              child: _FilterOption(
                title: filter.label,
                subtitle: filter.subtitle,
                icon: filter.icon,
                isSelected: _tempFilter == filter,
                onTap: () {
                  setState(() => _tempFilter = filter);
                  widget.onFilterChanged(filter);
                },
              ),
            ),
          ),
          gap(height: 8),
          GenericButtonWidget(
            onPressed: widget.onApplyFilter,
            text: "Apply Filter",
          ),
          gap(height: 8),
        ],
      ),
    );
  }
}

class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: w(60),
        height: h(3),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(h(88)),
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppColors.primaryColor
                : const Color(0xFFE0E0E0),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _FilterOptionIcon(icon: icon, isSelected: isSelected),
            gap(width: 16),
            Expanded(
              child: _FilterOptionText(
                title: title,
                subtitle: subtitle,
                isSelected: isSelected,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primaryColor,
                size: w(20),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterOptionIcon extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _FilterOptionIcon({required this.icon, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : const Color(0xFF757575),
        size: 22,
      ),
    );
  }
}

class _FilterOptionText extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;

  const _FilterOptionText({
    required this.title,
    required this.subtitle,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: t(14),
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.primaryColor : Colors.black87,
          ),
        ),
        gap(height: 3),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: t(12),
            color: Colors.grey[600],
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
