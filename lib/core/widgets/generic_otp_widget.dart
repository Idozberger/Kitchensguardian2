import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';
import 'package:pinput/pinput.dart';

class OtpField extends StatefulWidget {
  final bool preFilledStar;
  final bool isJoining;
  final String initialString;
  final bool enabled;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;
  const OtpField({
    super.key,
    this.onCompleted,
    this.preFilledStar = false,
    this.initialString = "",
    this.isJoining = false,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  State<OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<OtpField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialString);
  }

  @override
  void didUpdateWidget(covariant OtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller if the initial string actually changed
    if (oldWidget.initialString != widget.initialString) {
      _controller.text = widget.initialString;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      constraints: BoxConstraints(
        minWidth: w(55),
        minHeight: h(50),
        maxWidth: w(55),
        maxHeight: h(50),
      ),
      textStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: Colors.black,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.greyColor),
        borderRadius: BorderRadius.circular(h(10)),
      ),
    );

    return Pinput(
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      key: ValueKey(widget.isJoining),
      length: widget.isJoining ? 6 : 5,
      controller: _controller,
      separatorBuilder: (index) =>
          SizedBox(width: widget.isJoining ? w(4) : w(20)),
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor, width: 2),
          borderRadius: BorderRadius.circular(h(10)),
        ),
      ),
      errorPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.errorColor, width: 2),
          borderRadius: BorderRadius.circular(h(4)),
        ),
      ),
      preFilledWidget: widget.preFilledStar
          ? Text(
              "*",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.greyColor,
                fontWeight: FontWeight.w400,
                fontSize: t(25),
              ),
            )
          : null,
      keyboardType: TextInputType.text,
      onCompleted: widget.onCompleted,
    );
  }
}
