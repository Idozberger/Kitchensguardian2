import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/utils/show_toast.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:intl/intl.dart';

class SelectDateWidget extends StatefulWidget {
  final DateTime startDate;

  final ValueChanged<DateTime> onChanged;
  final bool entitlementIsActive;

  const SelectDateWidget({
    super.key,
    required this.startDate,
    required this.onChanged,

    required this.entitlementIsActive,
  });

  @override
  State<SelectDateWidget> createState() => _SelectDateWidgetState();
}

class _SelectDateWidgetState extends State<SelectDateWidget> {
  late List<DateTime> _days;

  @override
  void initState() {
    super.initState();

    _days = List.generate(7, (i) => widget.startDate.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Date", style: Theme.of(context).textTheme.headlineLarge),
        gap(height: 7),
        UpperTile(
          horizontalPadding: 14,
          widget: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _days.asMap().entries.map((entry) {
              final index = entry.key;
              final date = entry.value;
              final isSelected = _isSameDate(date, widget.startDate);
              final isLocked = !widget.entitlementIsActive && index > 2;

              return GestureDetector(
                onTap: () {
                  if (isLocked) {
                    AppToast.show(
                      "Only premium users can select more days",
                      ToastType.error,
                    );
                    return;
                  }

                  widget.onChanged(date);
                },
                child: Opacity(
                  opacity: isLocked ? 0.4 : 1,
                  child: Container(
                    width: w(40),
                    padding: gapSymmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xffFFFBEB)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryColor
                            : Colors.white,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          date.day.toString(),
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.black,
                                fontSize: t(12),
                              ),
                        ),
                        gap(height: 4),
                        Text(
                          DateFormat('EEE').format(date),
                          style: Theme.of(context).textTheme.headlineMedium!
                              .copyWith(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.black,
                                fontSize: t(12),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
