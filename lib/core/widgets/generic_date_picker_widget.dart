import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/navigation/paywall_navigation.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:foodkitchen/core/widgets/generic_container_tile_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:intl/intl.dart';

class SelectDateWidget extends StatefulWidget {
  final DateTime startDate;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onChanged;
  final bool hasPremiumAccess;

  const SelectDateWidget({
    super.key,
    required this.startDate,
    required this.onChanged,
    required this.hasPremiumAccess,
    this.selectedDate,
  });

  @override
  State<SelectDateWidget> createState() => _SelectDateWidgetState();
}

class _SelectDateWidgetState extends State<SelectDateWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late List<List<DateTime>> _weeks;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _generateWeeks();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _generateWeeks() {
    _weeks = List.generate(
      2,
      (weekIndex) => List.generate(
        7,
        (dayIndex) =>
            widget.startDate.add(Duration(days: weekIndex * 7 + dayIndex)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final currentSelected = widget.selectedDate ?? widget.startDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Select Date", style: Theme.of(context).textTheme.headlineLarge),

        gap(height: 7),

        SizedBox(
          height: h(92),
          child: PageView.builder(
            controller: _pageController,
            itemCount: 2,
            itemBuilder: (context, weekIndex) {
              final days = _weeks[weekIndex];

              return UpperTile(
                horizontalPadding: 14,
                widget: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: days.asMap().entries.map((entry) {
                    final dayIndex = entry.key;
                    final date = entry.value;
                    final isSelected = _isSameDate(date, currentSelected);

                    final globalIndex = weekIndex * 7 + dayIndex;
                    final isLocked = !widget.hasPremiumAccess && globalIndex > 2;

                    return GestureDetector(
                      onTap: () {
                        if (isLocked) {
                          openPaywallIfEnabled(context);
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
                              if (isLocked)
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    SizedBox(height: 1),
                                    Positioned(
                                      top: -h(8),

                                      left: -w(13),
                                      child: Image.asset(
                                        AppAssets.crownImage,
                                        height: h(24),
                                      ),
                                    ),
                                  ],
                                ),
                              Text(
                                date.day.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
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
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
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
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
