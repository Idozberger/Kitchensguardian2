import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:intl/intl.dart';

class SelectDateWidget extends StatefulWidget {
  final DateTime startDate;
  final ValueChanged<DateTime> onChanged;

  const SelectDateWidget({
    super.key,
    required this.startDate,
    required this.onChanged,
  });

  @override
  State<SelectDateWidget> createState() => _SelectDateWidgetState();
}

class _SelectDateWidgetState extends State<SelectDateWidget> {
  late DateTime _selectedDate;
  late List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.startDate;
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
          widget: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _days.map((date) {
              final isSelected = _isSameDate(date, _selectedDate);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  widget.onChanged(date);
                },
                child: Container(
                  padding: gapSymmetric(vertical: 10, horizontal: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xffFFFBEB) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryColor : Colors.white,
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
                              fontSize: t(15),
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
                              fontSize: t(15),
                            ),
                      ),
                    ],
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
