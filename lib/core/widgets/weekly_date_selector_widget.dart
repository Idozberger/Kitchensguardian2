import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';

class WeeklyDateSelector extends StatefulWidget {
  final DateTime today;
  final ValueChanged<DateTime> onChanged;

  const WeeklyDateSelector({
    super.key,
    required this.today,
    required this.onChanged,
  });

  @override
  State<WeeklyDateSelector> createState() => _WeeklyDateSelectorState();
}

class _WeeklyDateSelectorState extends State<WeeklyDateSelector> {
  late DateTime dateTime;
  DateTime _startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday % 7));
  }

  List<DateTime> _daysInWeek(DateTime date) {
    DateTime start = _startOfWeek(date);
    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  @override
  void initState() {
    dateTime = widget.today;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final weekDays = _daysInWeek(dateTime);
    final monthYear = "${_monthName(dateTime.month)} ${dateTime.year}";
    final weekNumber = "Week ${_weekOfMonth(dateTime)}";

    return UpperTile(
      widget: Column(
        children: [
          Padding(
            padding: gapSymmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(AppAssets.backArrowiOS),
                ),
                Column(
                  children: [
                    Text(
                      monthYear,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    gap(height: 5),
                    Text(
                      weekNumber,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(AppAssets.forwardArrowiOS),
                ),
              ],
            ),
          ),
          gap(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weekDays.map((day) {
              final isSelected =
                  day.day == dateTime.day && day.month == dateTime.month;
              return GestureDetector(
                onTap: () {
                  widget.onChanged(day);
                  setState(() {
                    dateTime = day;
                  });
                },
                child: Column(
                  children: [
                    Text(
                      _dayName(day.weekday),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    gap(height: 5),
                    CircleAvatar(
                      radius: h(16),
                      backgroundColor: isSelected
                          ? AppColors.primaryColor
                          : Colors.white,
                      child: Text(
                        "${day.day}",
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(
                              color: isSelected ? Colors.black : Colors.grey,
                            ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _dayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return "Mon";
      case DateTime.tuesday:
        return "Tue";
      case DateTime.wednesday:
        return "Wed";
      case DateTime.thursday:
        return "Thu";
      case DateTime.friday:
        return "Fri";
      case DateTime.saturday:
        return "Sat";
      default:
        return "Sun";
    }
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];
    return months[month - 1];
  }

  int _weekOfMonth(DateTime date) {
    int dayOfMonth = date.day;
    return ((dayOfMonth - 1) ~/ 7) + 1;
  }
}
