import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

enum PantryFilter { all, expiring, lowStock }

class MyPantryFilterSheet extends StatefulWidget {
  const MyPantryFilterSheet({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onApplyFilter,
  });

  final PantryFilter selectedFilter;
  final void Function(PantryFilter filter) onFilterChanged;
  final VoidCallback onApplyFilter;

  @override
  State<MyPantryFilterSheet> createState() => _MyPantryFilterSheetState();
}

class _MyPantryFilterSheetState extends State<MyPantryFilterSheet> {
  late PantryFilter _tempSelectedFilter;

  @override
  void initState() {
    super.initState();
    _tempSelectedFilter = widget.selectedFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: gapSymmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: w(60),
              height: h(3),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(h(88)),
              ),
            ),
          ),
          gap(height: 18),
          Center(
            child: Text(
              "Filter Items",
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          gap(height: 20),
          MyPantryFilterOption(
            title: 'All Items',
            subtitle: 'Show all pantry items',
            icon: Icons.inventory_2_outlined,
            isSelected: _tempSelectedFilter == PantryFilter.all,
            onTap: () {
              setState(() {
                _tempSelectedFilter = PantryFilter.all;
              });
              widget.onFilterChanged(PantryFilter.all);
            },
          ),
          gap(height: 12),
          MyPantryFilterOption(
            title: 'Expiring Soon',
            subtitle: 'Items that are about to expire',
            icon: Icons.access_time,
            isSelected: _tempSelectedFilter == PantryFilter.expiring,
            onTap: () {
              setState(() {
                _tempSelectedFilter = PantryFilter.expiring;
              });
              widget.onFilterChanged(PantryFilter.expiring);
            },
          ),
          gap(height: 12),
          MyPantryFilterOption(
            title: 'Low Stock',
            subtitle: 'Items running low',
            icon: Icons.warning_amber_outlined,
            isSelected: _tempSelectedFilter == PantryFilter.lowStock,
            onTap: () {
              setState(() {
                _tempSelectedFilter = PantryFilter.lowStock;
              });
              widget.onFilterChanged(PantryFilter.lowStock);
            },
          ),
          gap(height: 20),
          GenericButtonWidget(
            onPressed: widget.onApplyFilter,
            text: "Apply Filter",
          ),
        ],
      ),
    );
  }
}

class MyPantryFilterOption extends StatelessWidget {
  const MyPantryFilterOption({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

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
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryColor
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : const Color(0xFF757575),
                size: 24,
              ),
            ),
            gap(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.black87,
                    ),
                  ),
                  gap(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
