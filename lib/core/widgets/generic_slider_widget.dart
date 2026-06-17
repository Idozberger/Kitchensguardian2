import 'package:flutter/material.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
// syncfusion_flutter_core is a transitive dep of sliders; direct import needs this allow.
// ignore: depend_on_referenced_packages
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart'
    show SfRectangularTooltipShape, SfSlider;

class GenericSlider extends StatefulWidget {
  final double min;
  final double max;
  final double value;
  final double interval;
  final int minorTicksPerInterval;
  final bool showTicks;
  final bool showLabels;
  final bool enableTooltip;
  final ValueChanged<double> onChanged;

  const GenericSlider({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.interval = 5.0,
    this.minorTicksPerInterval = 0,
    this.showTicks = false,
    this.showLabels = false,
    this.enableTooltip = true,
  });

  @override
  State<GenericSlider> createState() => _GenericSliderState();
}

class _GenericSliderState extends State<GenericSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  String _formatToHoursMinutes(double value) {
    final totalMinutes = value.round();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      removeTop: true,
      child: SfSliderTheme(
        data: SfSliderThemeData(
          overlayRadius: 0,
          tooltipBackgroundColor: AppColors.primaryColor,
          tooltipTextStyle: Theme.of(context).textTheme.headlineMedium!
              .copyWith(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        child: SfSlider(
          shouldAlwaysShowTooltip: true,
          tooltipShape: const SfRectangularTooltipShape(),
          inactiveColor: const Color(0xffD9D9D9),
          activeColor: AppColors.primaryColor,
          min: widget.min,
          max: widget.max,
          value: _currentValue,
          interval: widget.interval,
          showTicks: widget.showTicks,
          showLabels: widget.showLabels,
          enableTooltip: widget.enableTooltip,
          minorTicksPerInterval: widget.minorTicksPerInterval,

          tooltipTextFormatterCallback:
              (Object? actualValue, String formattedText) {
                final double v = actualValue is num
                    ? actualValue.toDouble()
                    : double.tryParse(actualValue?.toString() ?? '') ??
                          _currentValue;
                return _formatToHoursMinutes(v);
              },

          onChanged: (Object? value) {
            final double v = value is num
                ? value.toDouble()
                : double.tryParse(value?.toString() ?? '') ?? _currentValue;
            setState(() {
              _currentValue = v;
            });
            widget.onChanged(v);
          },
        ),
      ),
    );
  }
}
