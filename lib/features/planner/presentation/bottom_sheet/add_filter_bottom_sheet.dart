import 'package:flutter/material.dart';
import 'package:foodkitchen/core/config/app_assets.dart';
import 'package:foodkitchen/core/global/functions/gaps.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/widgets/generic_button_widget.dart';
import 'package:foodkitchen/core/widgets/generic_gap_widget.dart';
import 'package:foodkitchen/core/widgets/generic_slider_widget.dart';
import 'package:foodkitchen/core/widgets/generic_text_form_field_widget.dart';

class AddFilterBottomSheet extends StatefulWidget {
  final VoidCallback callback;
  final void Function(double) onChanged;
  final double sliderValue;
  final TextEditingController controller;
  final TextEditingController hoursController;
  final TextEditingController minController;
  const AddFilterBottomSheet({
    super.key,
    required this.callback,
    required this.controller,
    required this.sliderValue,
    required this.hoursController,
    required this.minController,
    required this.onChanged,
  });

  @override
  State<AddFilterBottomSheet> createState() => _AddFilterBottomSheetState();
}

class _AddFilterBottomSheetState extends State<AddFilterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),

      child: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: gapAll(14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: w(80),
                    height: h(4),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(h(44)),
                    ),
                  ),
                ),
                gap(height: 18),
                Center(
                  child: Text(
                    "Add Filters",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                gap(height: 18),
                Row(
                  children: [
                    Text(
                      "Estimated Calories",
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(width: w(12)),
                    Image.asset(AppAssets.crownImage, height: h(22)),
                  ],
                ),
                gap(height: 8),
                Text(
                  "Add a calorie filter to guide the AI in generating recipes that match your calorie preference.",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                gap(height: 12),
                AppTextField(
                  hintText: "e.g, 450",
                  isLabled: false,
                  fillColor: Colors.white,
                  isFilled: true,
                  controller: widget.controller,
                  label: '',
                ),
                gap(height: 12),
                Text(
                  "Cooking Duration",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                gap(height: 8),

                Text(
                  "Add your custom cooking duration.",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                gap(height: 60),
                GenericSlider(
                  min: 0,
                  max: 300,
                  value: widget.sliderValue,
                  onChanged: widget.onChanged,
                ),

                gap(height: 22),
                GenericButtonWidget(
                  onPressed: () {
                    widget.callback();
                  },
                  text: "Add Filter",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
